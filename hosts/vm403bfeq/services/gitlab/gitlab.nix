{ config, lib, pkgs, ... }:
let
  gitlabPassword = "$(cat ${config.sops.secrets."servers/cygnus-labs/gitlab/databasePasswordFile".path})";
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
in
{
  imports = [
    ./runners/instance/docker-images.nix
    ./runners/infrastructure/alpine.nix
    ./runners/infrastructure/docker-images.nix
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
    };
  };

  environment.systemPackages = with pkgs.unstable; [
    glab
    fluxcd
  ];



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
        };
      };
      "registry.cygnus-labs.com" = {
        useACMEHost = "cygnus-labs.com";
        forceSSL = true;
        locations."/" = {
          extraConfig = ''
            client_max_body_size 0;
          '';
          proxyPass = "http://127.0.0.1:${toString config.services.gitlab.registry.port}";
        };
      };
    };
  };

  services.gitlab = {
    enable = true;

    databaseCreateLocally = false;
    databaseUsername = "gitlab";
    databasePasswordFile = "${config.sops.secrets."servers/cygnus-labs/gitlab/databasePasswordFile".path}";
    #databaseHost = "localhost";

    initialRootEmail = "nico.swan@cygnus-labs.com";
    initialRootPasswordFile = "${config.sops.secrets."servers/cygnus-labs/gitlab/initialRootPasswordFile".path}";

    https = true;
    host = "git.cygnus-labs.com";
    port = 443;
    user = "git";
    group = "git";
    smtp = {
      enable = true;
      username = "nico.swan@cygnus-labs.com";
      passwordFile = "${config.sops.secrets."servers/cygnus-labs/gitlab/smtpPasswordFile".path}";
      address = "mail.cygnus-labs.com";
      port = 465;
    };
    secrets = {
      dbFile = "${config.sops.secrets."servers/cygnus-labs/gitlab/secrets/dbFile".path}";
      secretFile = "${config.sops.secrets."servers/cygnus-labs/gitlab/secrets/secretsFile".path}";
      otpFile = "${config.sops.secrets."servers/cygnus-labs/gitlab/secrets/otpFile".path}";
      jwsFile = "${config.sops.secrets."servers/cygnus-labs/gitlab/secrets/jwsFile".path}";
    };
    registry = {
      enable = true;
      port = 5000;
      certFile = "${config.sops.secrets."servers/cygnus-labs/gitlab/secrets/registryCertFile".path}";
      keyFile = "${config.sops.secrets."servers/cygnus-labs/gitlab/secrets/registryKeyFile".path}";
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
