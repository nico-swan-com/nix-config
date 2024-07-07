# This function creates a NixOS system based 
{ nixpkgs, lib, outputs, inputs, hardware, ... }:

name:
{ system
, username
, fullName
, email
, darwin ? false
, wsl ? false
, extraModules ? [ ]
}:

let

  # True if this is a WSL system.
  isWSL = wsl;

  # The config files for this system.
  hostConfig = ../hosts/${name}/${if darwin then "darwin-configuration" else "configuration" }.nix;
  userHMConfig = ../hosts/${name}/home-manager.nix;

  # NixOS vs nix-darwin functionst
  systemFunc = if darwin then inputs.darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
  homeManagerModules = if darwin then inputs.home-manager.darwinModules else inputs.home-manager.nixosModules;

  configVars = import ../vars { inherit inputs username fullName email; };
  configLib = import ../lib { inherit lib; };

  # Custom modifications/overrides to upstream packages.
  overlays = import ../overlays { inherit inputs outputs; };

  specialArgs = { inherit inputs outputs configVars configLib nixpkgs darwin hardware isWSL; };

in
systemFunc rec {
  inherit specialArgs;
  inherit system;

  modules = [

    # Apply our overlays. Overlays are keyed by system type so we have
    # to go through and apply our system type. We do this first so
    # the overlays are available globally.
    #{ nixpkgs.overlays = overlays; }

    # Bring in WSL if this is a WSL build
    (if isWSL then inputs.nixos-wsl.nixosModules.wsl else { })

    #Disk partitioning 
    (if !darwin then inputs.disko.nixosModules.disko  else { })

    # Nix User Repository
    (if !darwin then inputs.nur.nixosModules.nur  else { })

    hostConfig
    homeManagerModules.home-manager
    {
      home-manager = {
        #backupFileExtension = "backup";
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = specialArgs;
        users.${configVars.username} = import userHMConfig {
          inherit configVars;
          pkgs = nixpkgs;
          isWSL = isWSL;
          inputs = inputs;
        };
      };
    }

    # We expose some extra arguments so that our modules can parameterize
    # better based on these values.
    {
      config._module.args = specialArgs;
    }
  ] ++ extraModules;
}
