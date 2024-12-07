{
  description = "Minimal NixOS configuration for bootstrapping systems";

  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
    # Declarative partitioning and formatting
    disko.url = "github:nix-community/disko";
    # Secrets management
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets
    nix-secrets = {
      url = "git+ssh://git@github.com/nico-swan-com/nix-secrets.git?ref=main&shallow=1";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      inherit (self) outputs;
      inherit (nixpkgs) lib;

      configLib = import ../lib { inherit lib; };
      minimalSpecialArgs = {
        inherit inputs outputs configLib;
      };

      # FIXME: Specify arch eventually probably
      # This mkHost is way better: https://github.com/linyinfeng/dotfiles/blob/8785bdb188504cfda3daae9c3f70a6935e35c4df/flake/hosts.nix#L358
      newConfig =
        name: disk: withSwap: swapSize:
        let
          cfg = {
            hostname = name;
            system = "x86_64-linux";
            username = "nicoswan";
            fullname = "Nico Swan";
            email = "hi@nicoswan.com";
            locale = "en_ZA.UTF-8";
            timezone = "Africa/Johannesburg";
            isMinimal = true;
          };

        in
        (nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = minimalSpecialArgs;
          modules = [
            inputs.disko.nixosModules.disko
            (configLib.relativeToRoot "hosts/${name}/configuration.nix")
            {
              _module.args = {
                inherit disk withSwap swapSize;
              };
              networking.hostName = name;
            }
          ];
        });
    in
    {
      nixosConfigurations = {
        # host = newConfig "name" disk" "withSwap" "swapSize" 
        # Swap size is in GiB
        media = newConfig "media" "/dev/sdb" false "0";

        # Custom ISO
        #
        # `just iso` - from nix-config directory to generate the iso standalone
        # 'just iso-install <drive>` - from nix-config directory to generate and copy directly to USB drive
        # `nix build ./nixos-installer#nixosConfigurations.iso.config.system.build.isoImage` - from nix-config directory to generate the iso manually
        #
        # Generated images will be output to the ~/nix-config/results directory unless drive is specified
        iso = nixpkgs.lib.nixosSystem {
          specialArgs = minimalSpecialArgs;
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
            ./iso
          ];
        };
      };
    };
}
