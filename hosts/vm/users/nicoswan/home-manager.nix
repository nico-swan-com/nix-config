{ pkgs, configLib, ... }:
{

  imports = [
    ../../../../common/home-manager/desktop/terminals/tmux.nix
  ];

  programs.nicoswan = {
    utils.google-cloud-sdk.enable = true;
    utils.kubernetes = {
      enable = true;
      additional-utils = true;
      admin-utils = true;
    };
  };
  # Install addition packages via home manager
  home.packages = with pkgs; [
    cmatrix # Some fun 
    glow # Terminal marckdown viewer
    lnav
  ];
}
