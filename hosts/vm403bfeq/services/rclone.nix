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
    mkdir -p /etc/rclone
    cat << EOF > /etc/rclone/rclone.conf
    [google-drive]
    type = drive
    scope = drive
    service_account_file = ${
      config.sops.secrets."servers/cygnus-labs/external-services/google/vm403bfeq-service-account.json".path
    }

    [encrypted-google-drive]
    type = crypt
    remote = google-drive:/encrypted
    password = ${password}
    password2 = ${password2}

    [encrypted-google-drive-backup]
    type = crypt
    remote = google-drive:/backup
    password = ${password}
    password2 = ${password2}
    EOF

    mkdir -p /root/.config/rclone
    rm /root/.config/rclone/rclone.conf
    ln -s /etc/rclone/rclone.conf /root/.config/rclone/rclone.conf


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
      "servers/cygnus-labs/external-services/google/vm403bfeq-service-account.json" =
        { };
      "servers/cygnus-labs/rclone/encryption/google-drive/password" = { };
      "servers/cygnus-labs/rclone/encryption/google-drive/password2" = { };
    };
  };

  environment.variables = { RCLONE_CONFIG_DIR = "/etc/rclone"; };

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

  #  fileSystems."/mnt/google-drive-unencrypted" = {
  #    device = "google-drive:/";
  #    fsType = "rclone";
  #    options = [
  #      "nodev"
  #      "nofail"
  #      "allow_other"
  #      "args2env"
  #      "config=/etc/rclone/rclone.conf"
  #    ];
  #  };

  systemd.services = {
    "rclone-mounts-google-drive-unencrypted" = {
      enable = true;
      description = "Mount rclone google-drive unencrypted folder.";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      preStart = "/usr/bin/env mkdir -p /mnt/google-drive-unencrypted";
      serviceConfig = {
        Type = "notify";
        ExecStart = ''
          ${pkgs.rclone}/bin/rclone --config=/etc/rclone/rclone.conf --vfs-cache-mode writes --ignore-checksum mount "google-drive:/" "/mnt/google-drive-unencrypted"
        '';
        ExecStop =
          "/run/wrappers/bin/fusermount -u /mnt/google-drive-unencrypted";
      };
      wantedBy = [ "default.target" ];
    };
  };

  systemd.services = {
    "rclone-mounts-google-drive-encrypted" = {
      enable = true;
      description = "Mount rclone google-drive encrypted folder.";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      preStart = "/usr/bin/env mkdir -p /mnt/google-drive-encrypted";
      serviceConfig = {
        Type = "notify";
        ExecStart = ''
          ${pkgs.rclone}/bin/rclone --config=/etc/rclone/rclone.conf --vfs-cache-mode writes --ignore-checksum mount "encrypted-google-drive:/" "/mnt/google-drive-encrypted"
        '';
        ExecStop =
          "/run/wrappers/bin/fusermount -u /mnt/google-drive-encrypted";
      };
      wantedBy = [ "default.target" ];
    };
  };

  systemd.services = {
    "rclone-mounts-encrypted-google-drive-backup" = {
      enable = true;
      description = "Mount rclone google-drive shared backup folder.";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      preStart =
        "/usr/bin/env mkdir -p /mnt/google-drive-shared-encrypted-backup";
      serviceConfig = {
        Type = "notify";
        ExecStart = ''
          ${pkgs.rclone}/bin/rclone --config=/etc/rclone/rclone.conf --vfs-cache-mode writes --ignore-checksum mount "encrypted-google-drive-backup:/" "/mnt/google-drive-shared-encrypted-backup"
        '';
        ExecStop =
          "/run/wrappers/bin/fusermount -u /mnt/google-drive-shared-encrypted-backup";
      };
      wantedBy = [ "default.target" ];
    };
  };
}

