{ config, lib, pkgs, ... }:
{
  # alacritty - a cross-platform, GPU-accelerated terminal emulator
  programs.alacritty = {
    enable = true;
    # custom settings
    settings = lib.attrsets.recursiveUpdate (import ./default-settings.nix) {
      # Import the Dracula theme
      import = ["${pkgs.alacritty-theme}/dracula_plus.toml"];
    };
  };

  home.packages = with pkgs.unstable; [
    alacritty-theme
  ];
}

