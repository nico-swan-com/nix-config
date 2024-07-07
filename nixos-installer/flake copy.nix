{
  description = "Minimal NixOS configuration for bootstrapping systems";

  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.05";
    # Declarative partitioning and formatting
    disko.url = "github:nix-community/disko";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      inherit (self) outputs;
      inherit (nixpkgs) lib;

      username = "nicoswan";
      fullName = "Nico Swan";
      email = "hi@nicoswan.com";


      configVars = import ../vars { inherit inputs lib username fullName email; };
      configLib = import ../lib { inherit lib; };
      minimalConfigVars = lib.recursiveUpdate configVars {
        isMinimal = true;
      };
      minimalSpecialArgs = {
        inherit inputs outputs configLib;
        configVars = minimalConfigVars;
      };

      # FIXME: Specify arch eventually probably
      # This mkHost is way better: https://github.com/linyinfeng/dotfiles/blob/8785bdb188504cfda3daae9c3f70a6935e35c4df/flake/hosts.nix#L358
      newConfig =
        name: disk: withSwap: swapSize:
        (nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = minimalSpecialArgs;
          modules = [
            inputs.disko.nixosModules.disko
            (configLib.relativeToRoot "hosts/common/disks/standard-disk-config.nix")
            {
              _module.args = {
                inherit disk withSwap swapSize;
              };
            }
            (configLib.relativeToRoot "hosts/${name}/configuration.nix")
            {
              networking.hostName = name;
            }
          ];
        });
    in
    {
      nixosConfigurations = {
        # host = newConfig "name" disk" "withSwap" "swapSize" 
        # Swap size is in GiB
        media = newConfig "media-server" "/dev/vda" false "0";
        # guppy = newConfig "guppy" "/dev/vda" false "0";
        # gusto = newConfig "gusto" "/dev/sda" true "8";

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
