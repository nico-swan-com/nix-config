{ lib, config, pkgs, ... }:

let cfg = config.services.gotrue;
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
  };

  config = lib.mkIf cfg.enable {
    systemd.services.gotrue = {
      description = "GoTrue Service";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.gotrue}/bin/gotrue";
        Environment = [
          "DATABASE_URL=${cfg.databaseUrl}"
          "GOTRUE_ADMIN_EMAIL=${cfg.adminEmail}"
          "GOTRUE_ADMIN_PASSWORD=${cfg.adminPassword}"
          "GOTRUE_JWT_SECRET=${cfg.jwtSecret}"
          "GOTRUE_SITE_URL=${cfg.siteUrl}"
        ];
        Restart = "on-failure";
      };
    };
  };
}

