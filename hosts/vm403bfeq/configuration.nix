{ pkgs, ... }:
{
  imports =
    [
      # Core configuration
      ../../core/nixos
      ./sops.nix

      ./system
      ./services

      ./extra-users.nix

    ];
  environment.systemPackages =  with pkgs; [
     clang
  ];

  virtualisation.vmVariant = {
    # following configuration is added only when building VM with build-vm
    virtualisation = {
      resolution = { x = 1280; y = 1024; };
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
