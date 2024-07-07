{ config, lib, pkgs, ... }:
{
  # alacritty - a cross-platform, GPU-accelerated terminal emulator
  programs.alacritty = {
    enable = true;
    # custom settings
    settings = lib.attrsets.recursiveUpdate (import ./default-settings.nix ) { } ;

  };

  home.packages = with pkgs; [
    alacritty-theme
  ];
}
