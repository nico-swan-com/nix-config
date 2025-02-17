{ config, lib, pkgs, ... }:
let
  gitlabPassword = "$(cat ${
      config.sops.secrets."servers/cygnus-labs/gitlab/databasePasswordFile".path
    })";
  keycloakCert = "$(cat ${
      config.sops.secrets."servers/cygnus-labs/keycloak/clients/gitlab-saml/cert".path
    })";
  keycloakFingerprint = "$(cat ${
      config.sops.secrets."servers/cygnus-labs/keycloak/clients/gitlab-saml/fingerprint".path
    })";
  createUserScript = pkgs.writeScript "createGitlabUser" ''
    # Check if the role exists
    ROLE_EXISTS=$(psql -U postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='gitlab'")

    # If the role does not exist, create it
    if [ -z "$ROLE_EXISTS" ]; then
       psql -U postgres -qc "CREATE ROLE gitlab LOGIN PASSWORD ${gitlabPassword};"
       echo "Postgres role 'gitlab' created with password."
    else
      # If the role exists, assign the password
      psql -U postgres -qc "ALTER ROLE gitlab WITH PASSWORD '${gitlabPassword}';"
      echo "Postgres password for role 'gitlab' has been updated."
    fi

  '';
in {
  imports = [
    ./runners/instance/docker-images.nix
    ./runners/infrastructure/alpine.nix
    ./runners/infrastructure/docker-images.nix
    ./runners/infrastructure/nix-runner.nix
    #./runners/default-runner.nix
    ./runners/nix-runner.nix
    ./runners/docker-images.nix
    ./runners/node.nix
  ];
  sops = {
    secrets = {
      "servers/cygnus-labs/gitlab/smtpPasswordFile" = {
        owner = "git";
        group = "git";
      };
      "servers/cygnus-labs/gitlab/databasePasswordFile" = {
        owner = "git";
        group = "git";
      };
      "servers/cygnus-labs/gitlab/initialRootPasswordFile" = {
        owner = "git";
        group = "git";
      };
      "servers/cygnus-labs/gitlab/secrets/dbFile" = {
        owner = "git";
        group = "git";
      };
      "servers/cygnus-labs/gitlab/secrets/secretsFile" = {
        owner = "git";
        group = "git";
      };
      "servers/cygnus-labs/gitlab/secrets/otpFile" = {
        owner = "git";
        group = "git";
      };
      "servers/cygnus-labs/gitlab/secrets/jwsFile" = {
        owner = "git";
        group = "git";
      };
      "servers/cygnus-labs/gitlab/secrets/registryCertFile" = {
        owner = "docker-registry";
        group = "git";
        mode = "0440";
      };
      "servers/cygnus-labs/gitlab/secrets/registryKeyFile" = {
        owner = "docker-registry";
        group = "git";
        mode = "0440";
      };
      "servers/cygnus-labs/keycloak/clients/gitlab-saml/cert" = {
        owner = "git";
        group = "git";
        mode = "0440";
      };
      "servers/cygnus-labs/keycloak/clients/gitlab-saml/fingerprint" = {
        owner = "git";
        group = "git";
        mode = "0440";
      };
    };
  };

  environment.systemPackages = with pkgs.unstable; [ glab fluxcd ];

  #services.openssh.enable = true;
  boot.kernel.sysctl."net.ipv4.ip_forward" = lib.mkForce true;

  #virtualisation.docker.enable = true;

  services.nginx = {

    virtualHosts = {
      "git.cygnus-labs.com" = {
        useACMEHost = "cygnus-labs.com";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
          extraConfig = ''
            client_max_body_size 0;
          '';
        };
      };
      "registry.cygnus-labs.com" = {
        useACMEHost = "cygnus-labs.com";
        forceSSL = true;
        locations."/" = {
          extraConfig = ''
            client_max_body_size 0;
          '';
          proxyPass =
            "http://127.0.0.1:${toString config.services.gitlab.registry.port}";
        };
      };
    };
  };

  services.gitlab = {
    enable = true;

    databaseCreateLocally = false;
    databaseUsername = "gitlab";
    databasePasswordFile =
      "${config.sops.secrets."servers/cygnus-labs/gitlab/databasePasswordFile".path}";

    initialRootEmail = "nico.swan@cygnus-labs.com";
    initialRootPasswordFile =
      "${config.sops.secrets."servers/cygnus-labs/gitlab/initialRootPasswordFile".path}";

    https = true;
    host = "git.cygnus-labs.com";
    port = 443;
    user = "git";
    group = "git";
    smtp = {
      enable = true;
      tls = true;
      domain = "cygnus-labs.com";
      username = "nico.swan@cygnus-labs.com";
      passwordFile =
        "${config.sops.secrets."servers/cygnus-labs/gitlab/smtpPasswordFile".path}";
      address = "mail.cygnus-labs.com";
      port = 465;
      enableStartTLSAuto = false;
    };
    secrets = {
      dbFile =
        "${config.sops.secrets."servers/cygnus-labs/gitlab/secrets/dbFile".path}";
      secretFile =
        "${config.sops.secrets."servers/cygnus-labs/gitlab/secrets/secretsFile".path}";
      otpFile =
        "${config.sops.secrets."servers/cygnus-labs/gitlab/secrets/otpFile".path}";
      jwsFile =
        "${config.sops.secrets."servers/cygnus-labs/gitlab/secrets/jwsFile".path}";
    };
    registry = {
      enable = true;
      port = 5000;
      certFile =
        "${config.sops.secrets."servers/cygnus-labs/gitlab/secrets/registryCertFile".path}";
      keyFile =
        "${config.sops.secrets."servers/cygnus-labs/gitlab/secrets/registryKeyFile".path}";
      externalPort = 443;
      defaultForProjects = true;
      externalAddress = "registry.cygnus-labs.com";
    };

    #    extraGitlabRb = ''
    #       gitlab_kas['internal_api_listen_network'] = 'unix'
    #       gitlab_kas['internal_api_listen_address'] = '/run/gitlab/gitlab-kas/sockets/internal-api.socket'
    #       gitlab_kas['private_api_listen_network'] = 'unix'
    #       gitlab_kas['private_api_listen_address'] = '/run/gitlab/gitlab-kas/sockets/private-api.socket'
    #    ''; 

    extraConfig = {
      gitlab = {
        email_from = "gitlab-no-reply@cygnus-labs.com";
        email_display_name = "Cygnus-Labs GitLab";
        email_reply_to = "gitlab-no-reply@cygnus-labs.com";
        default_projects_features = { builds = false; };
        artifacts.max_size = 1024;
      };
      #Keycloak SSO config 
      omniauth = {
        enabled = true;
        allow_single_sign_on = [ "saml" ];
        block_auto_created_users = false;
        auto_link_saml_user = true;

        #saml_enabled = true;
        #saml_assertion_consumer_url =
        #  "https://git.cygnus-labs.com/users/auth/saml/callback";
        #saml_sp_entity_id = "https://git.cygnus-labs.com";
        #saml_idp_cert_fingerprint =
        #  "E2:09:1A:7F:E6:18:74:D6:C2:CC:D8:AD:24:9C:12:89:11:E8:BD:F9";
        #saml_idp_sso_target_url =
        #  "https://keycloak.cygnus-labs.com/realms/production/protocol/saml";
        #saml_name_identifier_format =
        #  "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent";
        providers = [{
          name = "saml";
          label = "Cygnus-Labs";
          args = {
            assertion_consumer_service_url =
              "https://git.cygnus-labs.com/users/auth/saml/callback";
            #idp_cert = keycloakCert;
            idp_cert_fingerprint =
              "F4:08:AE:B2:E0:A9:DF:46:06:18:C2:35:6A:5C:5C:9F:F1:70:9F:A9";
            idp_sso_target_url =
              "https://keycloak.cygnus-labs.com/realms/production/protocol/saml";
            issuer = "git.cygnus-labs.com";
            name_identifier_format =
              "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent";
            attribute_statements = {
              username = [ "username" ];
              email = [ "email" ];
              first_name = [ "firstName" ];
              last_name = [ "lastName" ];
            };
            #            certificate: '-----BEGIN CERTIFICATE-----\n<redacted>\n-----END CERTIFICATE-----',
            #            private_key: '-----BEGIN PRIVATE KEY-----\n<redacted>\n-----END PRIVATE KEY-----',
            #            security: {
            #              authn_requests_signed: true,  # enable signature on AuthNRequest
            #              want_assertions_signed: true,  # enable the requirement of signed assertion
            #              want_assertions_encrypted: false,  # enable the requirement of encrypted assertion 
            #              metadata_signed: false,  # enable signature on Metadata
            #              signature_method: 'http://www.w3.org/2001/04/xmldsig-more#rsa-sha256',
            #              digest_method: 'http://www.w3.org/2001/04/xmlenc#sha256',
            #            }``
          };
        }];
      };
      #      gitlab_kas = {
      #        enabled = true;
      #        # The URL to the external KAS API (used by the Kubernetes agents)
      #        external_url = "wss://git.cygnus-labs.com/-/kubernetes-agent";
      #
      #        # The URL to the internal KAS API (used by the GitLab backend)
      #        internal_url = "grpc://localhost:8153";
      #
      #        # The URL to the Kubernetes API proxy (used by GitLab users)
      #        #external_k8s_proxy_url = "https://102.135.163.95:8154"; # default: nil
      #      };
    };

    #    backup = {
    #      uploadOptions
    #      startAt
    #      skip
    #      path
    #      keepTime
    #    };
  };

  systemd.services.gitlab-backup.environment.BACKUP = "dump";

}
