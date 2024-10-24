{ pkgs, configLib, ... }:
{

  imports = [

    ../../../../common/home-manager/desktop/common-desktop.nix
    
        # Terminal applictions
    ../../../../common/home-manager/terminal/lazygit.nix # Git UI
    ../../../../common/home-manager/terminal/lunarvim.nix # VIM IDE


    # Software Development 
    ../../../../common/home-manager/desktop/applications/vscode.nix
    ../../../../common/home-manager/development/node/node_20.nix


    # Desktop application
    ../../../../common/home-manager/desktop/applications/lens.nix
    ../../../../common/home-manager/desktop/applications/firefox.nix
    ../../../../common/home-manager/desktop/applications/google-chrome.nix
    
    #../../../../common/home-manager/desktop/applications/libraoffice.nix
    #../../../../common/home-manager/desktop/applications/obsidian.nix


    # Just for fun
    ../../../../common/home-manager/terminal/fun.nix
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
    gnome-extensions-cli
    cmatrix                      # Some fun 
    glow                         # Terminal marckdown viewer
    lnav    
  ];

  # home = {
  #   file.".kube/cygnus-labs-kubernetes-ca.pem".source = "${config.sops.secrets."ca.pem".path}";
  # };

}
