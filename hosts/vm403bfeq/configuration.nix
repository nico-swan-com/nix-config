{ pkgs, ... }: {
  imports = [
    # Core configuration
    ../../core/nixos
    ./sops.nix

    ./system
    ./services

    ./extra-users.nix

  ];
  environment.systemPackages = with pkgs; [
    clang
    opentofu
    # Added the below because hostname from net-tools doens pick up the domain
    inetutils
    (pkgs.writeShellScriptBin "hostname" ''
      exec ${pkgs.inetutils}/bin/hostname "$@"
    '')
  ];

  virtualisation.vmVariant = {
    # following configuration is added only when building VM with build-vm
    virtualisation = {
      resolution = {
        x = 1280;
        y = 1024;
      };
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
      };
    };
  };

  #nix = {
  #  settings = {
  #    extra-substituters = [
  #      "https://devenv.cachix.org"
  #    ];
  #    extra-trusted-public-keys = [
  #      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
  #    ];
  #  };
  #};
}
