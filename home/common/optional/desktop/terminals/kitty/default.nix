{ config, lib, pkgs, ... }:
{
  # alacritty - a cross-platform, GPU-accelerated terminal emulator
  programs.kitty = {
    enable = true;
    shellIntegration = {
      enableZshIntegration = true;
    };

    # custom settings
    # settings = lib.attrsets.recursiveUpdate (import ./default-settings.nix) { };

    # extraConfig = "include user.conf";

    # darwinLaunchOptions = [
    #       "--single-instance"
    #       "--directory=/tmp/my-dir"
    #       "--listen-on=unix:/tmp/my-socket"
    #     ];

    # keybindings = {
    #   "ctrl+c" = "copy_or_interrupt";
    # };


  };
}
