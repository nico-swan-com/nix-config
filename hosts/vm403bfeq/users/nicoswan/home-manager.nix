{ pkgs, configLib, ... }:
{

  imports = [
    # Terminal applictions
    ../../../../common/home-manager/terminal/lazygit.nix # Git UI
    #../../../../common/home-manager/terminal/lunarvim.nix # VIM IDE
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
    (writeShellScriptBin "update-kube-admin" (builtins.readFile scripts/update-kube-admin.sh))                      # Some fun 
    (writeShellScriptBin "remove-kubernetes" (builtins.readFile scripts/remove-kubernetes.sh))                      # Some fun 
    lnav   
    systemctl-tui
  ] ++ ( with pkgs.unstable; [
    lunarvim
  ]);




  # home = {
  #   file.".kube/cygnus-labs-kubernetes-ca.pem".source = "${config.sops.secrets."ca.pem".path}";
  # };

}
