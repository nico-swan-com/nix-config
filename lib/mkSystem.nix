{ nixpkgs, nixpkgs-unstable, inputs, outputs, lib, home-manager, nix-darwin
, hardware, ... }:
name:
{ system, username, fullname, email, locale, timezone, extraModules
, useStable ? [ ], sharedHMModules ? [ ], darwin ? false, isMinimal ? false }:

let
  inherit (nixpkgs) lib;
  cfg = {
    hostname = name;
    username = username;
    fullname = fullname;
    email = email;
    locale = locale;
    timezone = timezone;
    isDarwin = darwin;
    isMinimal = isMinimal;
    useSable = useStable;
  };

  configLib = import ../lib { inherit lib; };

  # Custom modifications/overrides to upstream packages.
  pkgs = if useStable then inputs.nixpkgs-stable else inputs.nixpkgs-unstable;
  overlays = import ../overlays { inherit pkgs inputs outputs; };

  # The config files for this system.
  configuration = ../hosts/${name}/configuration.nix;
  homeManagerConfig = ../hosts/${name}/home-manager.nix;

  # NixOS vs nix-darwin functions
  systemFunc = if darwin then
    inputs.nix-darwin.lib.darwinSystem
  else
    nixpkgs.lib.nixosSystem;
  homeManagerModules = if darwin then
    inputs.home-manager.darwinModules
  else
    inputs.home-manager.nixosModules;
  userHomeDirectory =
    if darwin then "/Users/${username}" else "/home/${username}";

  specialArgs = {
    inherit nixpkgs inputs outputs cfg configLib nixpkgs-unstable hardware
      nix-darwin;
    pkgs-stable = inputs.nixpkgs-stable;
  };

in systemFunc rec {
  inherit specialArgs;
  inherit system;
  modules = [
    # Apply our overlays. Overlays are keyed by system type so we have
    # to go through and apply our system type. We do this first so
    # the overlays are available globally.
    {
      nixpkgs.overlays = [
        overlays.additions
        overlays.modifications
        overlays.unstable-packages
        overlays.stable-packages
      ];
    }

    (if !darwin then {
      i18n.defaultLocale = lib.mkDefault locale;
      time.timeZone = lib.mkDefault timezone;
    } else
      { })
    {
      nixpkgs.config.allowUnfree = true;
      nix = {
        settings = {
          experimental-features = "nix-command flakes";
          auto-optimise-store = true;
          trusted-users = [ "root" "${cfg.username}" ];
          trusted-substituters = [ "https://devenv.cachix.org" ];
          trusted-public-keys = [
            "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
          ];
        };
      };
    }
    {
      # Users
      users.users."${username}" = {
        name = "${username}";
        home = userHomeDirectory;
        description = "${fullname}";
      };
    }
    configuration
    homeManagerModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        extraSpecialArgs = specialArgs;
        users.${username} = import homeManagerConfig {
          inherit cfg;
          pkgs = nixpkgs;
          inputs = inputs;
        };
        sharedModules = [ ../modules/home-manager ] ++ sharedHMModules;
      };
    }
    # We expose some extra arguments so that our modules can parameterize
    # better based on these values.
    { config._module.args = specialArgs; }
  ] ++ extraModules;
}
