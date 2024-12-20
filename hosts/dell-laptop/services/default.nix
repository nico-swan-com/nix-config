{ config, pkgs, ... }:
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

  imports = [
    # Core services
    ../../../common/nixos/services/virtualisation
    #./hydra.nix  # CI tool 
    #./kubernetes.nix # Container management
    #./nextcloud # Own home Cloud 
    #./appflowy-cloud
    ./postgres.nix
    ./minio.nix
    ./redis.nix
    ../../../modules/gotrue/default.nix
  ];

  services.onedrive = {
    enable = true;
    package = pkgs.unstable.onedrive;
  };

  services.gotrue = {
    enable = true;
    databaseUrl = "postgres://admin:${adminPassword}@localhost:5432/admin";
    adminEmail = "admin@example.com";
    adminPassword = "adminpassword";
    jwtSecret = "supersecret";
    siteUrl = "http://localhost:9999";
    smtpPassword = "${smtpPassword}";
  };
}
