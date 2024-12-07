{ cfg, ... }: {
  imports = [
    ../../core/home-manager
    ./users/${cfg.username}/home-manager.nix
    ../../common/home-manager/desktop/terminals/tmux.nix
    ../../common/home-manager/terminal/fun.nix
  ];
}
