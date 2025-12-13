{ ... }: {
  imports = [ ../../core/nixos ./sops.nix ./system ./services ./packages ];

  security.sudo.wheelNeedsPassword = false;

  programs.nix-ld.enable = true;
  home-manager.backupFileExtension = "backup";

  services.gvfs.enable = true;

  virtualisation.virtualbox.host.enable = true;

  # VM configuration for nixos-build-vm
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 8192;
      cores = 4;
      graphics = true;
      mountHostNixStore = true;
      sharedDirectories = {
        sops = {
          source = "/home/nicoswan/.config/sops/age";
          target = "/home/nicoswan/.config/sops/age";
          securityModel = "passthrough";
        };
      };
    };
  };
}
