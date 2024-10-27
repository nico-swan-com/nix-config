{ config, pkgs, ... }:
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
    };
  };

  #services.openssh.enable = true;

  #systemd.services.gitlab-backup.environment.BACKUP = "dump";

  security.acme = {
    defaults.email = "nico.swan@cygnus-labs.com";
    acceptTerms = true;
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "git.cygnus-labs.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
      };
      # "gitlab.cygnus-labs.com" = {
      #   #enableACME = true;
      #   #forceSSL = true;
      #   locations."/".proxyPass = "http://localhost:8080";
      # };
      # localhost = {
      #   locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
      # };
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
    extraConfig = {
      gitlab = {
        email_from = "gitlab-no-reply@cygnus-labs.com";
        email_display_name = "Cygnus-Labs GitLab";
        email_reply_to = "gitlab-no-reply@cygnus-labs.com";
        default_projects_features = { builds = false; };
      };
    };
  };
}
