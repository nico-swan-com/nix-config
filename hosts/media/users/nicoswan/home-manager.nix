{ pkgs, ... }:
{

  imports = [
    # Terminal applictions
    ../../../../common/home-manager/terminal/lazygit.nix # Git UI
  ];

  # Install addition packages via home manager
  home.packages = with pkgs.unstable; [
    systemctl-tui
    lnav
    lunarvim
  ];

  # home = {
  #   file.".kube/cygnus-labs-kubernetes-ca.pem".source = "${config.sops.secrets."ca.pem".path}";
  # };

}
