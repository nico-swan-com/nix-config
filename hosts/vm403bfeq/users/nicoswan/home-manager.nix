{ pkgs, configLib, ... }:
{

  imports = [
    # Terminal applictions
    ../../../../common/home-manager/terminal/lazygit.nix # Git UI
    ../../../../common/home-manager/terminal/lunarvim.nix # VIM IDE
  ];
 
  programs.nicoswan = {
    utils.google-cloud-sdk.enable = true;
    utils.kubernetes = {
      enable = false;
      additional-utils = true;
      admin-utils = true;
    };
  };
  # Install addition packages via home manager
  home.packages = with pkgs; [                      # Some fun 
    lnav   
    systemctl-tui 
  ];

  # home = {
  #   file.".kube/cygnus-labs-kubernetes-ca.pem".source = "${config.sops.secrets."ca.pem".path}";
  # };

}
