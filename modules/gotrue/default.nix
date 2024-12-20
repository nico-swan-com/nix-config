{ lib, config, pkgs, ... }:

let
  cfg = config.services.gotrue;

  # Script to generate rclone-google.conf
  gotrueConfigScript = pkgs.writeScript "generate-gotrue-config.sh" ''
        #!/bin/sh
        mkdir -p /etc/gotrue
        cat << EOF > /etc/gotrue/gotrue-environment.conf
              DATABASE_URL=${cfg.databaseUrl}
              GOTRUE_ADMIN_EMAIL=${cfg.adminEmail}
              GOTRUE_ADMIN_PASSWORD=${cfg.adminPassword}
              GOTRUE_JWT_SECRET=${cfg.jwtSecret}
              GOTRUE_SITE_URL=${cfg.siteUrl}
              GOTRUE_API_HOST=localhost
              API_EXTERNAL_URL=http://localhost:9999
              GOTRUE_ADMIN_EMAIL=
              GOTRUE_ADMIN_PASSWORD=password
              GOTRUE_DB_DRIVER=postgres
              GOTRUE_DISABLE_SIGNUP=false
              GOTRUE_OPERATOR_TOKEN=token123
              GOTRUE_EXTERNAL_DISCORD_CLIENT_ID=
              GOTRUE_EXTERNAL_DISCORD_ENABLED=false
              GOTRUE_EXTERNAL_DISCORD_REDIRECT_URI=http://localhost:9999/callback"
              GOTRUE_EXTERNAL_DISCORD_SECRET=
              GOTRUE_EXTERNAL_GITHUB_CLIENT_ID=
              GOTRUE_EXTERNAL_GITHUB_ENABLED=false
              GOTRUE_EXTERNAL_GITHUB_REDIRECT_URI=http://localhost:9999/callback"
              GOTRUE_EXTERNAL_GITHUB_SECRET=
              GOTRUE_EXTERNAL_GOOGLE_CLIENT_ID=
              GOTRUE_EXTERNAL_GOOGLE_ENABLED=false
              GOTRUE_EXTERNAL_GOOGLE_REDIRECT_URI=http://localhost:9999/callback"
              GOTRUE_EXTERNAL_GOOGLE_SECRET=
              GOTRUE_JWT_ADMIN_GROUP_NAME=supabase_admin
              GOTRUE_JWT_EXP=7200
              GOTRUE_JWT_SECRET=hello456
              GOTRUE_MAILER_AUTOCONFIRM=false
              GOTRUE_MAILER_URLPATHS_CONFIRMATION=/gotrue/verify
              GOTRUE_MAILER_URLPATHS_EMAIL_CHANGE=/gotrue/verify
              GOTRUE_MAILER_URLPATHS_INVITE=/gotrue/verify
              GOTRUE_MAILER_URLPATHS_RECOVERY=/gotrue/verify
              GOTRUE_RATE_LIMIT_EMAIL_SENT=1000
              GOTRUE_SITE_URL=appflowy-flutter://
              GOTRUE_SMTP_ADMIN_EMAIL=dev@cynus-labs.com
              GOTRUE_SMTP_HOST=mail.cygnus-labs.com
              GOTRUE_SMTP_MAX_FREQUENCY=1ns
              GOTRUE_SMTP_PASS=${cfg.smtpPassword}
              GOTRUE_SMTP_PORT=465
              GOTRUE_SMTP_USER=nico.swan@cygnus-labs.com
              PORT=9999
              URI_ALLOW_LIST=*
    EOF
  '';

  # Ensure the script is executable
  activationScript = pkgs.writeScript "activation-script.sh" ''
    echo ${gotrueConfigScript}

    ${gotrueConfigScript}
  '';

in {
  options.services.gotrue = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable GoTrue service.";
    };
    databaseUrl = lib.mkOption {
      type = lib.types.str;
      default = "postgres://user:password@localhost:5432/database";
      description = "Database connection URL.";
    };
    adminEmail = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Admin email.";
    };
    adminPassword = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Admin password.";
    };
    jwtSecret = lib.mkOption {
      type = lib.types.str;
      default = "supersecret";
      description = "JWT secret.";
    };
    siteUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://localhost:9999";
      description = "Site URL.";
    };
    smtpPassword = lib.mkOption {
      type = lib.types.str;
      description = "smpt password";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.generate-gotrue-config = {
      wantedBy = [ "multi-user.target" ];
      script = "${activationScript}";
    };

    systemd.services.gotrue = {
      description = "GoTrue Service";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.gotrue}/bin/gotrue";
        EnvironmentFile = "/etc/gotrue/gotrue-environment.conf";
        #        Environment = [
        #          "DATABASE_URL=${cfg.databaseUrl}"
        #          "GOTRUE_ADMIN_EMAIL=${cfg.adminEmail}"
        #          "GOTRUE_ADMIN_PASSWORD=${cfg.adminPassword}"
        #          "GOTRUE_JWT_SECRET=${cfg.jwtSecret}"
        #          "GOTRUE_SITE_URL=${cfg.siteUrl}"
        #          "API_EXTERNAL_URL=http://localhost:9999"
        #          "GOTRUE_ADMIN_EMAIL="
        #          "GOTRUE_ADMIN_PASSWORD=password"
        #          "GOTRUE_DB_DRIVER=postgres"
        #          "GOTRUE_DISABLE_SIGNUP=false"
        #          "GOTRUE_OPERATOR_TOKEN=token123"
        #          "GOTRUE_EXTERNAL_DISCORD_CLIENT_ID="
        #          "GOTRUE_EXTERNAL_DISCORD_ENABLED=false"
        #          "GOTRUE_EXTERNAL_DISCORD_REDIRECT_URI=http://localhost:9999/callback"
        #          "GOTRUE_EXTERNAL_DISCORD_SECRET="
        #          "GOTRUE_EXTERNAL_GITHUB_CLIENT_ID="
        #          "GOTRUE_EXTERNAL_GITHUB_ENABLED=false"
        #          "GOTRUE_EXTERNAL_GITHUB_REDIRECT_URI=http://localhost:9999/callback"
        #          "GOTRUE_EXTERNAL_GITHUB_SECRET="
        #          "GOTRUE_EXTERNAL_GOOGLE_CLIENT_ID="
        #          "GOTRUE_EXTERNAL_GOOGLE_ENABLED=false"
        #          "GOTRUE_EXTERNAL_GOOGLE_REDIRECT_URI=http://localhost:9999/callback"
        #          "GOTRUE_EXTERNAL_GOOGLE_SECRET="
        #          "GOTRUE_JWT_ADMIN_GROUP_NAME=supabase_admin"
        #          "GOTRUE_JWT_EXP=7200"
        #          "GOTRUE_JWT_SECRET=hello456"
        #          "GOTRUE_MAILER_AUTOCONFIRM=false"
        #          "GOTRUE_MAILER_URLPATHS_CONFIRMATION=/gotrue/verify"
        #          "GOTRUE_MAILER_URLPATHS_EMAIL_CHANGE=/gotrue/verify"
        #          "GOTRUE_MAILER_URLPATHS_INVITE=/gotrue/verify"
        #          "GOTRUE_MAILER_URLPATHS_RECOVERY=/gotrue/verify"
        #          "GOTRUE_RATE_LIMIT_EMAIL_SENT=1000"
        #          "GOTRUE_SITE_URL=appflowy-flutter://"
        #          "GOTRUE_SMTP_ADMIN_EMAIL=dev@cynus-labs.com"
        #          "GOTRUE_SMTP_HOST=mail.cygnus-labs.com"
        #          "GOTRUE_SMTP_MAX_FREQUENCY=1ns"
        #          "GOTRUE_SMTP_PASS=${cfg.smtpPassword}"
        #          "GOTRUE_SMTP_PORT=465"
        #          "GOTRUE_SMTP_USER=nico.swan@cygnus-labs.com"
        #          "PORT=9999"
        #          "URI_ALLOW_LIST=*"
        #        ];
        Restart = "on-failure";
      };
    };
  };
}

