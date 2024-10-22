{ cfg, ... }:
{
  imports = [
    ../../core/home-manager
    ./users/${cfg.username}/home-manager.nix
  ];

  programs.nicoswan = {
    utils.google-cloud-sdk.enable = true;
    utils.kubernetes = {
      enable = true;
      additional-utils = true;
      admin-utils = true;
    };
  };
}
