{ config, lib, ... }:
let

  adminPassword = "$(cat ${
      config.sops.secrets."servers/cygnus-labs/postgres/users/admin/password".path
    })";
  smtpPassword = "$(cat ${
      config.sops.secrets."servers/cygnus-labs/smtp/passwordFile".path
    })";

in {
  sops = {
    secrets = { "servers/cygnus-labs/postgres/users/admin/password" = { }; };
    secrets = { "servers/cygnus-labs/smtp/passwordFile" = { }; };
  };

  virtualisation.oci-containers.containers."appflowy-cloud-gotrue" = {
    image = "appflowyinc/gotrue:latest";
    environment = {
      "API_EXTERNAL_URL" = "http://localhost:9999";
      "DATABASE_URL" =
        "postgres://admin:${adminPassword}@localhost:5432/postgres";
      "GOTRUE_ADMIN_EMAIL" = "";
      "GOTRUE_ADMIN_PASSWORD" = "password";
      "GOTRUE_DB_DRIVER" = "postgres";
      "GOTRUE_DISABLE_SIGNUP" = "false";
      "GOTRUE_EXTERNAL_DISCORD_CLIENT_ID" = "";
      "GOTRUE_EXTERNAL_DISCORD_ENABLED" = "false";
      "GOTRUE_EXTERNAL_DISCORD_REDIRECT_URI" = "http://localhost:9999/callback";
      "GOTRUE_EXTERNAL_DISCORD_SECRET" = "";
      "GOTRUE_EXTERNAL_GITHUB_CLIENT_ID" = "";
      "GOTRUE_EXTERNAL_GITHUB_ENABLED" = "false";
      "GOTRUE_EXTERNAL_GITHUB_REDIRECT_URI" = "http://localhost:9999/callback";
      "GOTRUE_EXTERNAL_GITHUB_SECRET" = "";
      "GOTRUE_EXTERNAL_GOOGLE_CLIENT_ID" = "";
      "GOTRUE_EXTERNAL_GOOGLE_ENABLED" = "false";
      "GOTRUE_EXTERNAL_GOOGLE_REDIRECT_URI" = "http://localhost:9999/callback";
      "GOTRUE_EXTERNAL_GOOGLE_SECRET" = "";
      "GOTRUE_JWT_ADMIN_GROUP_NAME" = "supabase_admin";
      "GOTRUE_JWT_EXP" = "7200";
      "GOTRUE_JWT_SECRET" = "hello456";
      "GOTRUE_MAILER_AUTOCONFIRM" = "false";
      "GOTRUE_MAILER_URLPATHS_CONFIRMATION" = "/gotrue/verify";
      "GOTRUE_MAILER_URLPATHS_EMAIL_CHANGE" = "/gotrue/verify";
      "GOTRUE_MAILER_URLPATHS_INVITE" = "/gotrue/verify";
      "GOTRUE_MAILER_URLPATHS_RECOVERY" = "/gotrue/verify";
      "GOTRUE_RATE_LIMIT_EMAIL_SENT" = "1000";
      "GOTRUE_SITE_URL" = "appflowy-flutter://";
      "GOTRUE_SMTP_ADMIN_EMAIL" = "dev@cynus-labs.com";
      "GOTRUE_SMTP_HOST" = "mail.cygnus-labs.com";
      "GOTRUE_SMTP_MAX_FREQUENCY" = "1ns";
      "GOTRUE_SMTP_PASS" = "${smtpPassword}";
      "GOTRUE_SMTP_PORT" = "465";
      "GOTRUE_SMTP_USER" = "nico.swan@cygnus-labs.";
      "PORT" = "9999";
      "URI_ALLOW_LIST" = "*";
    };
    #dependsOn = [ "appflowy-cloud-postgres" ];
    log-driver = "journald";
    extraOptions = [
      ''--health-cmd=["nc", "-z", "localhost", "9999"]''
      "--health-interval=5s"
      "--health-retries=6"
      "--health-timeout=5s"
      "--network=host"
      #"--network-alias=gotrue"
      #"--network=appflowy-cloud_default"
    ];
  };

  systemd.services."podman-appflowy-cloud-gotrue" = {
    serviceConfig = { Restart = lib.mkOverride 90 "on-failure"; };
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
    partOf = [ "podman-compose-appflowy-cloud-root.target" ];
    wantedBy = [ "podman-compose-appflowy-cloud-root.target" ];
  };

}
