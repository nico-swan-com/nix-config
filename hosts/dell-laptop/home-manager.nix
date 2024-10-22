{ cfg, ... }: {

  imports = [
    ../../core/home-manager
    ./users/${cfg.username}/home-manager.nix
    #../../common/home-manager/desktop/fonts.nix
    ../../common/home-manager/terminal/nnn.nix

    #../../packages/custom/read-aloud/home-manager-module.nix
  ];

}
