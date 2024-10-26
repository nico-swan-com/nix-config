{ config, lib, pkgs, ... }:
{
  # alacritty - a cross-platform, GPU-accelerated terminal emulator
  programs.kitty = {
    enable = true;
    # custom settings
    # settings = lib.attrsets.recursiveUpdate (import ./default-settings.nix) { };

  };
}
