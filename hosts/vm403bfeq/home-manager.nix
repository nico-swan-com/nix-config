{ cfg, ... }: {
  imports = [
    ../../core/home-manager
    ./users/${cfg.username}/home-manager.nix
    # ./users/deployer/home-manager.nix
    ../../common/home-manager/development/node/node_20.nix
  ];
}
