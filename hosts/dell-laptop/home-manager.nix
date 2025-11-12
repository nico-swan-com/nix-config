{ cfg, ... }: {
  imports = [
    ../../core/home-manager
    ./users/${cfg.username}/home-manager.nix
    ../../common/home-manager/terminal/nnn.nix
  ];
}
