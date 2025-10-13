{ config, ... }:
let
  passwordFile =
    "${config.sops.secrets."servers/cygnus-labs/restic/passwordFile".path}";
in {
  sops = { secrets = { "servers/cygnus-labs/restic/passwordFile" = { }; }; };

  networking.firewall = {
    allowedTCPPorts = [
      2456 # Valheim server
      2457 # Valheim server
    ];
  };

  system.activationScripts = {
    valheim-create-directories = {
      text = ''
        mkdir -p  /opt/game-servers/valheim-server/config/worlds /opt/game-servers/valheim-server/data
      '';
      deps = [ ];
    };
  };

  virtualisation.oci-containers.containers = {
    valheim = {
      serviceName = "valheim-server";
      image = "lloesche/valheim-server";
      volumes = [
        "/opt/game-servers/valheim-server/config:/config"
        "/opt/game-servers/valheim-server/data:/opt/valheim"
      ];
      environment = {
        SERVER_NAME = "Skyrim";
        WORLD_NAME = "Skyrim2";
        SERVER_PASS = "secrets";
        BACKUPS_MAX_COUNT = "2";
      };
      #extraOptions = [ "--cap-add=sys_nice" "--stop-timeout 120" ];

      ports = [ "2456-2457:2456-2457/udp" ];
    };
  };

  services.restic = {
    backups = {
      valheim-backup-home-nfs = {
        initialize = true;
        passwordFile = "${passwordFile}";
        paths = [ "/opt/game-servers/valheim-server/config" ];
        repository =
          "/mnt/home/ntfs_drive/backup/cygnus-labs/game-servers/valheim";
      };

    };
  };
}
