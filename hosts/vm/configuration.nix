{ pkgs, cfg, ... }:
{
  imports = [
    ../../core/nixos
    ./sops.nix
    ./system
  ];

  virtualisation.vmVariant = {
    # following configuration is added only when building VM with build-vm
    virtualisation = {
      memorySize = 8192; 
      cores = 4;
      graphics = false;
      mountHostNixStore = true;
      sharedDirectories= {
        sops = {
          source = "/home/nicoswan/.config/sops/age";
          target = "/home/nicoswan/.config/sops/age";
          securityModel = "passthrough";
        };
      };
    };
  };
}

