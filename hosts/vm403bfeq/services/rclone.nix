{ config, pkgs, ... }:
# 
# This service create mount config for cloud storage for backups
#
let
  # Decrypt the passwords
  password = "$(cat ${
      config.sops.secrets."servers/cygnus-labs/rclone/encryption/google-drive/password".path
    })";
  password2 = "$(cat ${
      config.sops.secrets."servers/cygnus-labs/rclone/encryption/google-drive/password2".path
    })";

  # Script to generate rclone-google.conf
  rcloneConfigScript = pkgs.writeScript "generate-rclone-config.sh" ''
    #!/bin/sh

    cat << EOF > /etc/rclone-google.conf
    [google-drive]
    type = drive
    scope = drive
    service_account_file = ${
      config.sops.secrets."servers/cygnus-labs/services/google/vm403bfeq-service-account.json".path
    }

    [encrypted-google-drive]
    type = crypt
    remote = google-drive:/
    password = ${password}
    password2 = ${password2}

    [google-drive-shared]
    type = drive
    scope = drive
    service_account_file = ${
      config.sops.secrets."servers/cygnus-labs/services/google/vm403bfeq-service-account.json".path
    }
    shared_with_me = true

    [encrypted-google-drive-shared]
    type = crypt
    remote = google-drive-shared:data/
    password = ${password}
    password2 = ${password2}
    EOF
  '';

  # Ensure the script is executable
  activationScript = pkgs.writeScript "activation-script.sh" ''
    echo ${rcloneConfigScript}

    ${rcloneConfigScript}
  '';

in {
  environment.systemPackages = [ pkgs.unstable.rclone pkgs.sops ];

  sops = {
    secrets = {
      "servers/cygnus-labs/services/google/vm403bfeq-service-account.json" =
        { };
      "servers/cygnus-labs/rclone/encryption/google-drive/password" = { };
      "servers/cygnus-labs/rclone/encryption/google-drive/password2" = { };
    };
  };

  systemd.services.generate-rclone-config = {
    wantedBy = [ "multi-user.target" ];
    script = "${activationScript}";
  };

  services.nginx = {
    virtualHosts = {
      "rclone.cygnus-labs.com" = {
        useACMEHost = "cygnus-labs.com";
        forceSSL = true;
        locations."/".proxyPass = "http://127.0.0.1:5572";
      };
    };
  };

  fileSystems."/mnt/google-drive" = {
    device = "encrypted-google-drive:/";
    fsType = "rclone";
    options = [
      "nodev"
      "nofail"
      "allow_other"
      "args2env"
      "config=/etc/rclone-google.conf"
    ];
  };

  fileSystems."/mnt/google-drive-shared" = {
    device = "encrypted-google-drive-shared:/";
    fsType = "rclone";
    options = [
      "nodev"
      "nofail"
      "allow_other"
      "args2env"
      "config=/etc/rclone-google.conf"
    ];
  };
  fileSystems."/mnt/google-drive-shared-unencrypted" = {
    device = "google-drive-shared:";
    fsType = "rclone";
    options = [
      "nodev"
      "nofail"
      "allow_other"
      "args2env"
      "config=/etc/rclone-google.conf"
    ];
  };
}

