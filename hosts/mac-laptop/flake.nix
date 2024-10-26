{
  description = "This is the base developer configuration for BCB";

  inputs = {
    # Secrets
    #
    # IMPORTANT
    # Replace the link with your secrets repository
    # The automated script `just install` only temprarilly substitues the url.
    #
    nix-secrets = {
      url = "git+ssh://git@github.com/nico-swan-com/nix-secrets.git?ref=main&shallow=1";
      flake = false;
    };

    # NixOS
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable"; # also see 'unstable-packages' overlay at 'overlays/default.nix"

    # Add bcb packages and modules
    bcb = {
      url = "git+ssh://git@gitlab.com/bcb-projects/bcb-internal-dev-tooling/bcb-nixpkgs.git?ref=main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # MacOS packages
    nix-darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # User packages
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets management
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    { self
    , nixpkgs
    #, nixpkgs-unstable
    , nix-darwin
    , home-manager
    , bcb
    , ...
    } @inputs:
    let
      inherit (self) outputs;
      inherit (nixpkgs) lib;

      # Systems that can run tests:
      supportedSystems = [ "aarch64-darwin" ];

      # Function to generate a set based on supported systems:
      forAllSystems = inputs.nixpkgs.lib.genAttrs supportedSystems;

      # Attribute set of nixpkgs for each system:
      nixpkgsFor =
        forAllSystems (system: import inputs.nixpkgs { inherit system; });

      mkSystem = bcb.mkSystem {
        inherit nixpkgs outputs inputs lib nix-darwin home-manager;
      };

      pkgs = nixpkgs;
      overlays = import ../overlays { inherit pkgs inputs outputs; };

    in
    {

      # TODO change this to something that has better looking output rules
      # Nix formatter available through 'nix fmt' https://nix-community.github.io/nixpkgs-fmt
      formatter = forAllSystems
        (system:
          nixpkgs.legacyPackages.${system}.nixpkgs-fmt
        );

      # Shell configured with packages that are typically only needed when working on or with nix-config.
      devShells = forAllSystems
        (system:
          let pkgs = nixpkgs.legacyPackages.${system};
          in import ./shell.nix { inherit pkgs; }
        );

      #
      #
      # IMPORTANT
      # Ensure that your user details are correct for the host you are using
      #
      # Main configuration
      darwinConfigurations.main = mkSystem "main" {
        system = "aarch64-darwin";
        username = "Nico.Swan";
        fullname = "Nico Swan";
        email = "nico@bcbgroup.io";
        locale = "en_ZA.UTF-8";
        timezone = "Africa/Johannesburg";
        darwin = true;
        extraModules = [
        ./configuration.nix
        {
          #nixpkgs.overlays = [ overlays.additions overlays.modifications overlays.unstable-packages ];
          #nixpkgs.overlays = [ overlays.unstable-packages ];
          nixpkgs.overlays = [
            (
              self: super: {
                ceryx = super.callPackage ./packages/ceryx/default.nix { };
              }
            )
            ( 
              final: _prev: {
                unstable = import inputs.nixpkgs-unstable {
                  system = final.system;
                  config.allowUnfree = true;
                };
              }
            )
          ];
        }
        ];
        extraHMModules = [ ./home.nix ];
      };
  };
}

