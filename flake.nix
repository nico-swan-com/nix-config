{
  description = "Example flake to apply nicoswan nixpkgs";

  inputs = {

    # Hardware
    hardware.url = "github:nixos/nixos-hardware";

    # NixOS
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable"; # also see 'unstable-packages' overlay at 'overlays/default.nix"


    # MacOS packages
    nix-darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # User packages
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix User Repository
    nur.url = "github:nix-community/NUR";
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };


    # Add nicoswan packages and modules 
    # nicoswan = {
    #   url = "github:nico-swan-com/nixpkgs/main";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.home-manager .follows = "home-manager";
    # };

    # Secrets management
    sops-nix = {
      url = "github:mic92/sops-nix";
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets
    nix-secrets = {
      url = "git+ssh://git@github.com/nico-swan-com/nix-secrets.git?ref=main&shallow=1";
      flake = false;
    };

    # Declarative partitioning and formatting
    disko.url = "github:nix-community/disko";

    #neovim
    # Neve.url = "github:redyf/Neve";
    #nixvim = {
    #    #url = "github:nix-community/nixvim";
    #    url = "github:nix-community/nixvim/nixos-24.11";
    #    # If using a stable channel you can use `url = "github:nix-community/nixvim/nixos-<version>"`
    #    inputs.nixpkgs.follows = "nixpkgs-unstable";
    #};
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , hardware
    , nix-darwin
    , home-manager
    , disko
    #, nixvim
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

      mkSystem = import ./lib/mkSystem.nix {
        inherit nixpkgs nixpkgs-unstable outputs inputs lib nix-darwin home-manager hardware;
      };

      # Common Configuration 
      commonConfig = {
          username = "nicoswan";
          fullname = "Nico Swan";
          email = "hi@nicoswan.com";
          locale = "en_ZA.UTF-8";
          timezone = "Africa/Johannesburg";
      };

      x86_64-config = lib.recursiveUpdate commonConfig {
          system = "x86_64-linux";
          # sharedHMModules = [
          #   nixvim.homeManagerModules.nixvim
          # ];
          extraModules = [
            inputs.nur.nixosModules.nur
            #
          ];
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

      # darwinConfigurations.darwin = mkSystem "darwin" {
      #   system = "aarch64-darwin";
      #   username = "nicoswan";
      #   fullname = "Nico Swan";
      #   email = "hi@nicoswan.com";
      #   locale = "en_ZA.UTF-8";
      #   timezone = "Africa/Johannesburg";
      #   darwin = true;
      #   extraModules = [ ./configuration.nix ];
      #   extraHMModules = [ ./home.nix ];
      # };

      nixosConfigurations = {
        vm = mkSystem "vm" x86_64-config;

        dell-laptop = mkSystem "dell-laptop" x86_64-config;
        asus-laptop = mkSystem "asus-laptop" x86_64-config;

        media = mkSystem "media" (lib.recursiveUpdate x86_64-config {
          extraModules = [ disko.nixosModules.disko ];
        });
        
        vm403bfeq = mkSystem "vm403bfeq" x86_64-config;
      };
  };
}
