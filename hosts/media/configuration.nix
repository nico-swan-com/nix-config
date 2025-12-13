{ pkgs, ... }: {
  imports = [
    # Core configuration
    ../../core/nixos
    ./sops.nix

    ./system
    ./services

  ];
  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [ fuse3 ];

  virtualisation.vmVariant = {
    # following configuration is added only when building VM with build-vm
    virtualisation = {
      memorySize = 8192;
      cores = 4;
      graphics = false;
      mountHostNixStore = true;
      sharedDirectories = {
        sops = {
          source = "/home/nicoswan/.config/sops/age";
          target = "/home/nicoswan/.config/sops/age";
          securityModel = "passthrough";
        };
        jackett = {
          source = "/tmp";
          target = "/mnt/media_storage/Media/jackett";
        };
        ombi = {
          source = "/tmp";
          target = "/mnt/media_storage/Media/Ombi";
        };
        plex = {
          source = "/tmp";
          target =
            "/mnt/media_storage/Media/Plex/plexmediaserver/Library/Application Support/Plex Media Server";
        };
        qbittorrent = {
          source = "/tmp";
          target = "/mnt/media_storage/Media/qbittorrent";
        };
        radarr = {
          source = "/tmp";
          target = "/mnt/media_storage/Media/Radarr";
        };
        sonarr = {
          source = "/tmp";
          target = "/mnt/media_storage/Media/Sonarr";
        };
        tautulli = {
          source = "/tmp";
          target = "/mnt/media_storage/Media/tautulli";
        };
      };
    };
  };

}

