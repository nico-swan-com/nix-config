{
  description = "Example flake to apply nicoswan nixpkgs";

  inputs = {

    # Hardware
    hardware.url = "github:nixos/nixos-hardware";

    # NixOS
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-25.11";
    nixpkgs-unstable.url =
      "github:NixOS/nixpkgs/nixos-unstable"; # also see 'unstable-packages' overlay at 'overlays/default.nix"

    # User packages
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # Nix User Repository
    nur.url = "github:nix-community/NUR";
    sops-nix = {
      url = "github:mic92/sops-nix";
    };

    # Secrets
    nix-secrets = {
      url =
        "git+ssh://git@github.com/nico-swan-com/nix-secrets.git?ref=main&shallow=1";
      flake = false;
    };

    # Declarative partitioning and formatting
    disko.url = "github:nix-community/disko";

    distro-grub-themes = {
      url = "github:AdisonCavani/distro-grub-themes";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    git-project-updater = {
      url = "github:/nico-swan-com/git-project-updater";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, hardware
    , home-manager, ... }@inputs:
    let
      inherit (self) outputs;
      inherit (nixpkgs) lib;

      # Function to generate a set based on supported systems:
      forAllSystems = inputs.nixpkgs.lib.genAttrs [ "x86_64-linux" ];

      mkSystem = import ./lib/mkSystem.nix {
        inherit nixpkgs nixpkgs-unstable outputs inputs lib
          home-manager hardware;
      };

      # Common system configuration
      x86_64-config = {
        system = "x86_64-linux";
        username = "nicoswan";
        fullname = "Nico Swan";
        email = "hi@nicoswan.com";
        locale = "en_ZA.UTF-8";
        timezone = "Africa/Johannesburg";
        extraModules = [ inputs.nur.modules.nixos.default ];
      };

    in {
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./packages/default.nix { inherit pkgs; });

      # Nix formatter available through 'nix fmt'
      formatter =
        forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);

      # Development shell
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./shell.nix { inherit pkgs; });

      # NixOS configurations
      nixosConfigurations = {
        dell-laptop = mkSystem "dell-laptop" (lib.recursiveUpdate x86_64-config {
          extraModules =
            [ inputs.distro-grub-themes.nixosModules.x86_64-linux.default ];
        });
      };

    };
}
