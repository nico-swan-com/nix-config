{ cfg, ... }: {

  imports = [
    ../../core/home-manager
    ./users/${cfg.username}/home-manager.nix

    #../../packages/custom/read-aloud/home-manager-module.nix
  ];

}
