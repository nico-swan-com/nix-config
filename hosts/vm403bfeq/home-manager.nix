{ cfg, ... }:
{
  imports = [
    ../../core/home-manager
    ./users/${cfg.username}/home-manager.nix
    # ./users/deployer/home-manager.nix
  ];
}
