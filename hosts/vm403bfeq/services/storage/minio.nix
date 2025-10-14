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
    path = [ pkgs.minio-client pkgs.coreutils pkgs.gnugrep pkgs.bash pkgs.glibc ];
    script = ''
      set -euo pipefail

      mc alias set local http://localhost:9000 "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD" || true

      ###########################################################
      # Create buckets
      ###########################################################

      # Create pretoria bucket
      mc mb --ignore-existing local/pretoria-files || true
      mc version enable local/pretoria-files || true
      mc ilm rule add local/pretoria-files --noncurrent-expire-days "30" --expire-delete-marker
      
      # Create cape town bucket
      mc mb --ignore-existing local/capetown-files || true
      mc version enable local/capetown-files || true
      mc ilm rule add local/capetown-files --noncurrent-expire-days "30" --expire-delete-marker
      
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

      # Replication user and policy
      if ! mc admin user info local "$MINIO_REPLICATION_ACCESS_KEY" >/dev/null 2>&1; then
        mc admin user add local "$MINIO_REPLICATION_ACCESS_KEY" "$MINIO_REPLICATION_SECRET_KEY" || true
      fi
      mc admin policy attach local staff-full-access-policy --user "$MINIO_REPLICATION_ACCESS_KEY" || true
      mc admin policy attach local bucket-replication-policy --user "$MINIO_REPLICATION_ACCESS_KEY" || true

      ###########################################################
      # Create bucket replication
      ###########################################################

      # Bucket replication policy
      if ! mc replicate info local/pretoria-files >/dev/null 2>&1; then
        mc replicate add local/pretoria-files --remote-bucket "http://$MINIO_REPLICATION_ACCESS_KEY:$MINIO_REPLICATION_SECRET_KEYY@http://169.239.182.94:9000/pretoria-files"
      fi
      # if ! mc replicate info local/capetown-files >/dev/null 2>&1; then
      #  mc replicate add local/capetown-files --remote-bucket "http://$MINIO_REPLICATION_ACCESS_KEY:$MINIO_REPLICATION_SECRET_KEY@http://169.239.182.94:9000/capetown-files"
      # fi

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


