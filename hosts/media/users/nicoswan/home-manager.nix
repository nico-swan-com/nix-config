{ pkgs,  ... }:
{

  imports = [
    # Terminal applictions
    ../../../../common/home-manager/terminal/lazygit.nix # Git UI
    ../../../../common/home-manager/terminal/lunarvim.nix # VIM IDE
  ];
 
  # Install addition packages via home manager
  home.packages = with pkgs; [
    systemctl-tui
    lnav    
  ];

  # home = {
  #   file.".kube/cygnus-labs-kubernetes-ca.pem".source = "${config.sops.secrets."ca.pem".path}";
  # };

}
