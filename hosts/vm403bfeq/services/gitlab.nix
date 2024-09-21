{ config, ... }:
{
  sops = {
    secrets = {
      "servers/cygnus-labs/smtp/password" = { };
      "servers/cygnus-labs/gitlab/dbPassword" = { };
      "servers/cygnus-labs/gitlab/rootPassword" = { };
      "servers/cygnus-labs/gitlab/dbFile" = { };
      "servers/cygnus-labs/gitlab/dbSecret" = { };
      "servers/cygnus-labs/gitlab/otpFile" = { };
      "servers/cygnus-labs/gitlab/jwsFile" = { };
    };
  };

  # services.nginx = {
  #   virtualHosts."git.cygnus-labs.com" = {
  #     enableACME = true;
  #     forceSSL = true;
  #     locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
  #   };
  # };

  services.gitlab = {
    enable = true;
    databasePasswordFile = "${config.sops.secrets."servers/cygnus-labs/gitlab/dbPassword".path}";
    databaseHost = "localhost";
    initialRootEmail = "nico.swan@cygnus-labs.com";
    initialRootPasswordFile = "${config.sops.secrets."servers/cygnus-labs/gitlab/rootPassword".path}";
    https = false;
    host = "localhost";
    port = 11443;
    user = "git";
    group = "git";
    smtp = {
      enable = true;
      username = "nico.swan@cygnus-labs.com";
      passwordFile = "${config.sops.secrets."servers/cygnus-labs/smtp/password".path}";
      address = "mail.cygnus-labs.com";
      port = 465;
    };
    secrets = {
      dbFile = "${config.sops.secrets."servers/cygnus-labs/gitlab/dbFile".path}";
      secretFile = "${config.sops.secrets."servers/cygnus-labs/gitlab/dbSecret".path}";
      otpFile = "${config.sops.secrets."servers/cygnus-labs/gitlab/otpFile".path}";
      jwsFile = "${config.sops.secrets."servers/cygnus-labs/gitlab/jwsFile".path}";
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
