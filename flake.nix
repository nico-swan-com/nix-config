{
  description = "Nico Swan";

  inputs = {
    # Hardware
    hardware.url = "github:nixos/nixos-hardware";

    # NixOS
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable"; # also see 'unstable-packages' overlay at 'overlays/default.nix"

    # MacOS packages
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Build a custom WSL installer
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # User packages
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix User Repository
    nur.url = github:nix-community/NUR;
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    # Declarative partitioning and formatting
    disko.url = "github:nix-community/disko";

    # kubernettes
    # kubenix.url = "github:hall/kubenix";


    # authentik-nix = {
    #   url = "github:nix-community/authentik-nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , darwin
    , hardware
    , ...
    } @inputs:
    let
      inherit (self) outputs;
      inherit (nixpkgs) lib;

      # Systems that can run tests:
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" "aarch64-linux" ];

      # Function to generate a set based on supported systems:
      forAllSystems = inputs.nixpkgs.lib.genAttrs supportedSystems;

      # Attribute set of nixpkgs for each system:
      nixpkgsFor =
        forAllSystems (system: import inputs.nixpkgs { inherit system; });

      mkSystem = import ./lib/mksystem.nix {
        inherit inputs outputs lib nixpkgs nixpkgs-unstable darwin hardware;
      };

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

      # Work Macbook pro 
      darwinConfigurations.macbook-pro-m1 = mkSystem "macbook-pro-m1" {
        system = "aarch64-darwin";
        username = "Nico.Swan";
        fullName = "Nico Swan";
        email = "nico@bcbgroup.io";
        darwin = true;
      };


      # NixOS
      nixosConfigurations = {

        nixos = mkSystem "dell-laptop" {
          system = "x86_64-linux";
          username = "nicoswan";
          fullName = "Nico Swan";
          email = "hi@nicoswan.com";
        };

        dell-laptop = mkSystem "dell-laptop" {
          system = "x86_64-linux";
          username = "nicoswan";
          fullName = "Nico Swan";
          email = "hi@nicoswan.com";
        };

        asus-laptop = mkSystem "asus-laptop" {
          system = "x86_64-linux";
          username = "nicoswan";
          fullName = "Nico Swan";
          email = "hi@nicoswan.com";
        };

        # Home media server 
        media = mkSystem "media-server" {
          system = "x86_64-linux";
          username = "nicoswan";
          fullName = "Nico Swan";
          email = "hi@nicoswan.com";
        };


        #Cloud.co.za VPS 8GB RAM
        vps = mkSystem "vm403bfeq" {
          system = "x86_64-linux";
          username = "nicoswan";
          fullName = "Nico Swan";
          email = "nico.swan@cygnus-labs.com";
        };
      };
    };
}
