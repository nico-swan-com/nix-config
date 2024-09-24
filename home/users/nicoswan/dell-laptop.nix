{ config, pkgs, inputs, ... }:
{

  imports = [
    ./common.nix
    ./common-desktop.nix
    ../../common/optional/sops.nix


    # Terminal applictions
    ../../common/optional/terminal/lazygit.nix # Git UI
    ../../common/optional/terminal/lunarvim.nix # VIM IDE


    # Software Development 
    ../../common/optional/desktop/applications/vscode.nix
    ../../common/optional/development/node/node_20.nix


    # Desktop application
    ../../common/optional/desktop/applications/lens.nix
    ../../common/optional/desktop/applications/firefox.nix
    ../../common/optional/desktop/applications/google-chrome.nix
    #../../common/optional/desktop/applications/libraoffice.nix
    #../../common/optional/desktop/applications/obsidian.nix


    # Just for fun
    #../../common/optional/terminal/fun.nix
  ];


  home.packages = with pkgs; [
    gnome-extensions-cli
  ];


  # home = {
  #   file.".kube/cygnus-labs-kubernetes-ca.pem".source = "${config.sops.secrets."ca.pem".path}";
  # };



}
