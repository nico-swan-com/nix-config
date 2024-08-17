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

      mkSystem = import ./lib/mksystem.nix {
        inherit inputs outputs lib nixpkgs;
      };

    in
    {

      nixosConfigurations = {

        # Media Server 
        nixosConfigurations = {
          media = mkSystem "media-server" {
            system = "x86_64-linux";
            username = "nicoswan";
            fullName = "Nico Swan";
            email = "hi@nicoswan.com";
          };
        };
      };


    };
}
