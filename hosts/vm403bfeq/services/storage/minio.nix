{ pkgs, config, ... }:
let
  commonExtraConfig = ''
    # Allow special characters in headers
    ignore_invalid_headers off;

    # Allow any size file to be uploaded.
    # Set to a value such as 1000m; to restrict file size to a specific value
    client_max_body_size 0;

    # Disable buffering
    proxy_buffering off;
    proxy_request_buffering off;
  '';
  passwordFile =
    "${config.sops.secrets."servers/cygnus-labs/restic/passwordFile".path}";

########################################################
# Policies
########################################################
  clientPolicyJson = pkgs.writeText "minio-client-upload-policy.json" ''
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": ["s3:PutObject", "s3:GetObject"],
          "Resource": ["arn:aws:s3:::pretoria-files/client-*/*"]
        }
      ]
    }
  '';
  staffPolicyJson = pkgs.writeText "minio-staff-full-access-policy.json" ''
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": ["s3:*"],
          "Resource": ["arn:aws:s3:::pretoria-files/*","arn:aws:s3:::capetown-files/*"]
        }
      ]
    }
  '';

  bucketReplicationPolicyJson = pkgs.writeText "minio-bucket-replication-policy.json" ''
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": ["s3:ReplicateObject"],
          "Resource": ["arn:aws:s3:::pretoria-files/*","arn:aws:s3:::capetown-files/*"]
        }
      ]
    }
  '';   
in {
  sops = {
    secrets = {
      "servers/cygnus-labs/minio/rootCredentialsFiles" = { };
      "servers/cygnus-labs/restic/passwordFile" = { };
      # UI credentials env file must define MINIO_UI_ACCESS_KEY and MINIO_UI_SECRET_KEY
      "servers/cygnus-labs/minio/uiCredentials" = { };
      # App credentials env file must define MINIO_APP_ACCESS_KEY and MINIO_APP_SECRET_KEY
      "servers/cygnus-labs/minio/appCredentials" = { };
      # Replication credentials env file must define MINIO_REPLICATION_ACCESS_KEY and MINIO_REPLICATION_SECRET_KEY
      "servers/cygnus-labs/minio/replicationCredentials" = { };
    };
  };

  environment.systemPackages = with pkgs; [ minio-client ];

  services.nginx = {
    virtualHosts = {
      "s3.cygnus-labs.com" = {
        forceSSL = false;
        enableACME = false;

        extraConfig = commonExtraConfig + ''
          add_header Content-Security-Policy "default-src 'self' 'unsafe-eval' 'unsafe-inline'; font-src 'self' data:;";
        '';

        locations."/" = {
          proxyPass = "http://localhost:9000";
          recommendedProxySettings = true;
          proxyWebsockets = true;
          extraConfig = ''
            proxy_connect_timeout 300;
            proxy_set_header Connection "";
            chunked_transfer_encoding off;
          '';
        };
      };

      "minio-console.platform.cygnus-labs.com" = {
        useACMEHost = "cygnus-labs.com";
        forceSSL = true;

        extraConfig = commonExtraConfig + ''
          add_header Content-Security-Policy "default-src 'self' 'unsafe-eval' 'unsafe-inline'; font-src 'self' data:;";
        '';

        locations."/" = {
          proxyPass = "http://localhost:9001";
          recommendedProxySettings = true;
          proxyWebsockets = true;

          extraConfig = ''
            proxy_set_header X-NginX-Proxy true;
            real_ip_header X-Real-IP;
            proxy_connect_timeout 300;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            chunked_transfer_encoding off;
          '';
        };
      };
    };
  };

  # S3 compatible storage service
  services.minio = {
    enable = true;
    package = pkgs.unstable.minio;
    region = "af-south-1";
    rootCredentialsFile =
      config.sops.secrets."servers/cygnus-labs/minio/rootCredentialsFiles".path;
  };

  # MinIO with OpenID Connect SSO support
  services.minio-sso = {
    enable = true;
    
    openid = {
      configUrl = "https://keycloak.cygnus-labs.com/realms/production/.well-known/openid-configuration";
      clientId = "minio-openid";
      clientSecret = "H5h6afFQx2hqfKxsZxYudWxvzBOYFZHx";
      scopes = "openid,profile,email";
      displayName = "Cygnus SSO";
      claimName = "preferred_username";
      redirectUri = "https://minio-console.platform.cygnus-labs.com/oauth_callback";
      redirectUriDynamic = true;
    };
    
    # Use the same environment file for consistency
    environmentFile = config.sops.secrets."servers/cygnus-labs/minio/rootCredentialsFiles".path;
  };

    # Bootstrap MinIO: create buckets, enable versioning, add example policies
  systemd.services.minio-bootstrap = {
    description = "Bootstrap MinIO resources for file-management";
    after = [ "minio.service" "network-online.target" "remote-fs.target" ];
    wants = [ "minio.service" "network-online.target" "remote-fs.target" ];
    unitConfig.RequiresMountsFor = [ "/mnt/pretoria" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = 5;
      EnvironmentFile = [
        config.sops.secrets."servers/cygnus-labs/minio/rootCredentialsFiles".path
        config.sops.secrets."servers/cygnus-labs/minio/uiCredentials".path
        config.sops.secrets."servers/cygnus-labs/minio/appCredentials".path
        config.sops.secrets."servers/cygnus-labs/minio/replicationCredentials".path
      ];
      Environment = "HOME=/root";
    };
    path = [ pkgs.minio-client pkgs.coreutils pkgs.gnugrep pkgs.bash pkgs.glibc pkgs.jq pkgs.curl ];
    script = ''
      set -euo pipefail

      mc alias set local http://localhost:9000 "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD" || true

      ###########################################################
      # Debug: Print important environment variables (mask secrets)
      ###########################################################
      print_env_var() {
        var_name="$1"
        val="$(printenv "$var_name" 2>/dev/null || true)"
        if [ -n "$val" ]; then
          case "$var_name" in
            *SECRET*|*PASSWORD*|*KEY*)
              printf '%s=%s\n' "$var_name" "[REDACTED]" ;;
            *)
              printf '%s=%s\n' "$var_name" "$val" ;;
          esac
        else
          printf '%s=\n' "$var_name"
        fi
      }

      echo "[minio-bootstrap] Debug: Selected environment variables"
      for v in \
        MINIO_SERVER_URL \
        MINIO_BROWSER_REDIRECT_URL \
        MINIO_IDENTITY_OPENID_CONFIG_URL \
        MINIO_IDENTITY_OPENID_CLIENT_ID \
        MINIO_IDENTITY_OPENID_CLIENT_SECRET \
        MINIO_IDENTITY_OPENID_SCOPES \
        MINIO_IDENTITY_OPENID_VENDOR \
        MINIO_IDENTITY_OPENID_KEYCLOAK_REALM \
        MINIO_IDENTITY_OPENID_KEYCLOAK_ADMIN_URL \
        MINIO_REPLICATION_ACCESS_KEY \
        MINIO_REPLICATION_SECRET_KEY \
      ; do
        print_env_var "$v"
      done

      # Quick probe: OIDC discovery URL reachable (non-fatal)c
      if [ -n "''${MINIO_IDENTITY_OPENID_CONFIG_URL-}" ]; then
        if curl -sfL "$MINIO_IDENTITY_OPENID_CONFIG_URL" >/dev/null; then
          echo "[minio-bootstrap] OIDC discovery URL reachable"
        else
          echo "[minio-bootstrap] Warning: OIDC discovery URL NOT reachable: $MINIO_IDENTITY_OPENID_CONFIG_URL"
        fi
      fi

      ###########################################################
      # Create buckets
      ###########################################################

      # Create pretoria bucket
      mc mb --ignore-existing local/pretoria-files || true
      mc version enable local/pretoria-files || true
      # Add lifecycle rule only if no rules exist (preserve any user-defined rules)
      pretoria_ilm_json="$(mc ilm rule ls local/pretoria-files --json 2>/dev/null || true)"
      [ -z "$pretoria_ilm_json" ] && pretoria_ilm_json='{"config":{"Rules":[]}}'
      pretoria_ilm_count="$(printf '%s' "$pretoria_ilm_json" | jq -r '.config.Rules | length // 0')"
      if [ "$pretoria_ilm_count" = "0" ]; then
        mc ilm rule add local/pretoria-files --noncurrent-expire-days "30" --expire-delete-marker || true
      else
        echo "ILM: existing rules detected on pretoria-files; not adding bootstrap rule"
      fi
      
      # Create cape town bucket
      mc mb --ignore-existing local/capetown-files || true
      mc version enable local/capetown-files || true
      # Add lifecycle rule only if no rules exist (preserve any user-defined rules)
      capetown_ilm_json="$(mc ilm rule ls local/capetown-files --json 2>/dev/null || true)"
      [ -z "$capetown_ilm_json" ] && capetown_ilm_json='{"config":{"Rules":[]}}'
      capetown_ilm_count="$(printf '%s' "$capetown_ilm_json" | jq -r '.config.Rules | length // 0')"
      if [ "$capetown_ilm_count" = "0" ]; then
        mc ilm rule add local/capetown-files --noncurrent-expire-days "30" --expire-delete-marker || true
      else
        echo "ILM: existing rules detected on capetown-files; not adding bootstrap rule"
      fi
      
      ###########################################################
      # Create policies
      ###########################################################

      # Install example policies from research doc (idempotent)
      mc admin policy create local client-upload-policy ${clientPolicyJson} || true
      mc admin policy create local staff-full-access-policy ${staffPolicyJson} || true
      mc admin policy create local bucket-replication-policy ${bucketReplicationPolicyJson} || true

      ###########################################################
      # Create users and attach policies
      # NOTE: When creating a new user, you must first create the user and then attach the policy to the user.
      # HowTo: Create a unique key and secret for the user. `openssl rand -base64 30` This needs to be in your nix secrets.
      ###########################################################

      # Create UI user and attach policy (idempotent)
      if ! mc admin user info local "$MINIO_UI_ACCESS_KEY" >/dev/null 2>&1; then
        mc admin user add local "$MINIO_UI_ACCESS_KEY" "$MINIO_UI_SECRET_KEY" || true
      fi
      mc admin policy attach local staff-full-access-policy --user "$MINIO_UI_ACCESS_KEY" || true

      # Create App user and attach policy (idempotent)
      if ! mc admin user info local "$MINIO_APP_ACCESS_KEY" >/dev/null 2>&1; then
        mc admin user add local "$MINIO_APP_ACCESS_KEY" "$MINIO_APP_SECRET_KEY" || true
      fi
      mc admin policy attach local staff-full-access-policy --user "$MINIO_APP_ACCESS_KEY" || true

      # Replication user and policy (only if credentials are available)
      if [ -n "''${MINIO_REPLICATION_ACCESS_KEY:-}" ] && [ -n "''${MINIO_REPLICATION_SECRET_KEY:-}" ]; then
        if ! mc admin user info local "$MINIO_REPLICATION_ACCESS_KEY" >/dev/null 2>&1; then
          mc admin user add local "$MINIO_REPLICATION_ACCESS_KEY" "$MINIO_REPLICATION_SECRET_KEY" || true
        fi
        mc admin policy attach local staff-full-access-policy --user "$MINIO_REPLICATION_ACCESS_KEY" || true
        mc admin policy attach local bucket-replication-policy --user "$MINIO_REPLICATION_ACCESS_KEY" || true
      else
        echo "Warning: MINIO_REPLICATION_ACCESS_KEY or MINIO_REPLICATION_SECRET_KEY not set. Skipping replication user creation."
      fi

      ###########################################################
      # Create bucket replication (only if credentials are available)
      ###########################################################

      # Check if replication credentials are available
      if [ -n "''${MINIO_REPLICATION_ACCESS_KEY:-}" ] && [ -n "''${MINIO_REPLICATION_SECRET_KEY:-}" ]; then
        echo "Setting up bucket replication with credentials..."
        
        # Bucket replication policy: list existing rules; if any exist, skip add
        pretoria_repl_stream="$(mc replicate list local/pretoria-files --json 2>/dev/null || true)"
        pretoria_repl_count="$(printf '%s' "$pretoria_repl_stream" | jq -s 'map(select(.status=="success") | .rule) | length')"
        if [ "$pretoria_repl_count" = "0" ]; then
          mc replicate add local/pretoria-files --priority 1 --remote-bucket "http://$MINIO_REPLICATION_ACCESS_KEY:$MINIO_REPLICATION_SECRET_KEY@169.239.182.94:9000/pretoria-files" || true
        else
          echo "Replication: rules already present for pretoria-files; skipping add"
        fi
        # if ! mc replicate info local/capetown-files >/dev/null 2>&1; then
        #  mc replicate add local/capetown-files --remote-bucket "http://$MINIO_REPLICATION_ACCESS_KEY:$MINIO_REPLICATION_SECRET_KEY@169.239.182.94:9000/capetown-files"
        # fi
      else
        echo "Warning: MINIO_REPLICATION_ACCESS_KEY or MINIO_REPLICATION_SECRET_KEY not set. Skipping bucket replication setup."
      fi

      ###########################################################
      # Configure SSO (OpenID Connect) for MinIO Console (idempotent, at end)
      ###########################################################

      if [ -n "''${MINIO_IDENTITY_OPENID_CONFIG_URL:-}" ] \
        && [ -n "''${MINIO_IDENTITY_OPENID_CLIENT_ID:-}" ] \
        && [ -n "''${MINIO_IDENTITY_OPENID_CLIENT_SECRET:-}" ]; then
        echo "Configuring MinIO OIDC (SSO) using identity_openid..."
        oidc_cfg_json="$(mc admin config get local identity_openid --json 2>/dev/null || true)"
        existing_client_id="$(printf '%s' "$oidc_cfg_json" | jq -r '(.identity_openid.client_id // .client_id // empty)' 2>/dev/null || true)"
        if [ -z "$existing_client_id" ] || [ "$existing_client_id" = "null" ]; then
          mc admin config set local identity_openid \
            config_url="$MINIO_IDENTITY_OPENID_CONFIG_URL" \
            client_id="$MINIO_IDENTITY_OPENID_CLIENT_ID" \
            client_secret="$MINIO_IDENTITY_OPENID_CLIENT_SECRET" \
            scopes="''${MINIO_IDENTITY_OPENID_SCOPES:-openid,profile,email}" \
            display_name="''${MINIO_IDENTITY_OPENID_DISPLAY_NAME:-SSO Login}" \
            redirect_uri_dynamic="''${MINIO_IDENTITY_OPENID_REDIRECT_URI_DYNAMIC:-on}" || true
          # Restart MinIO to apply identity provider config (avoid TTY requirement in mc)
          systemctl restart minio.service || true
          # Wait for API to be ready
          echo "Waiting for minio.service to become active..."
          for i in $(seq 1 60); do
            if systemctl is-active --quiet minio.service && curl -sf http://localhost:9000/minio/health/ready >/dev/null; then
              echo "minio.service is active and ready."
              break
            fi
            sleep 1
          done
          if ! systemctl is-active --quiet minio.service; then
            echo "Warning: minio.service did not become active within timeout; continuing anyway"
          fi
        else
          echo "OIDC already configured (client_id=$existing_client_id); skipping"
        fi
      else
        echo "OIDC env vars not fully set; skipping OIDC configuration"
      fi


    '';
  };

  services.restic = {
    backups = {

      minio-backup-home-nfs = {
        initialize = true;
        passwordFile = "${passwordFile}";
        paths = [ "/var/lib/minio/data" "/var/lib/minio/config" ];
        repository = "/mnt/home/ntfs_drive/backup/cygnus-labs/minio";
      };

      minio-backup-google-drive = {
        initialize = true;
        passwordFile = "${passwordFile}";
        paths = [ "/var/lib/minio/data" "/var/lib/minio/config" ];
        repository = "rclone:encrypted-google-drive-backup:/restic-repo/minio";
      };

    };
  };
}


