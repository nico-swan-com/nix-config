{ nixpkgs, nixpkgs-unstable, inputs, outputs, lib, home-manager
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
  # Check if nix-darwin is available in inputs
  hasNixDarwin = builtins.hasAttr "nix-darwin" inputs;
  systemFunc = if darwin then
    (if !hasNixDarwin then
      throw "nix-darwin input is required when darwin = true. Add it to your flake inputs."
    else
      inputs.nix-darwin.lib.darwinSystem)
  else
    nixpkgs.lib.nixosSystem;
  homeManagerModules = if darwin then
    inputs.home-manager.darwinModules
  else
    inputs.home-manager.nixosModules;
  userHomeDirectory =
    if darwin then "/Users/${username}" else "/home/${username}";

  specialArgs = {
    inherit nixpkgs inputs outputs cfg configLib nixpkgs-unstable hardware;
    pkgs-stable = inputs.nixpkgs-stable;
  } // (if darwin && hasNixDarwin then { nix-darwin = inputs.nix-darwin; } else { });

  # Build pkgs explicitly with our overlays and pass to nixosSystem so the same
  # package set (including noto-fonts-subset workaround) is used for fonts.conf,
  # home-manager-path, and all modules. Otherwise the nixpkgs module may use
  # a different base (e.g. from another input) and our overlay is not applied.
  pkgsWithOverlays =
    import nixpkgs {
      inherit system;
      overlays = [
        overlays.additions
        overlays.modifications
        overlays.unstable-packages
        overlays.stable-packages
      ];
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "beekeeper-studio-5.3.4"
        ];
      };
    };

in systemFunc rec {
  inherit specialArgs;
  inherit system;
  pkgs = pkgsWithOverlays;
  modules = [
    # Overlays are applied via pkgs above; keep option in sync for any code that reads it.
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
      # nixpkgs.config omitted: we pass pkgs = pkgsWithOverlays (built with that config).
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
          pkgs = pkgsWithOverlays;
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
