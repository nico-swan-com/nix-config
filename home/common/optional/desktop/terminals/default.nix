{ config, pkgs, lib, ... }: {

  imports = [
    ./alacritty
    ./kitty
    ./tmux.nix
  ];
}
