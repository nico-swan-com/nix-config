{ pkgs, ... }:
{
  imports = [
    ./applications/vscode/vscode.nix
    ./terminals/alacritty
    ./terminals/kitty
    ./terminals/tmux.nix
  ];

  home.packages = with pkgs; [
    #cryptomator
    obsidian
    google-chrome
  ];

}

