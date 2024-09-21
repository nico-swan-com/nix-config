{ pkgs, ... }:
{

  imports = [
    ./common.nix
    ./common-desktop.nix

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

  sops = {
    secrets = {
      "ca.pem" = {
        sopsFile = ../../../hosts/vm403bfeq/services/kubernetes/certificates.yaml;
        path = "/home/nicoswan/.kube/cygnus-labs-kubernetes-ca.pem";
      };
      "cluster-admin.pem" = {
        sopsFile = ../../../hosts/vm403bfeq/services/kubernetes/certificates.yaml;
        path = "/home/nicoswan/.kube/cygnus-labs-kubernetes-cluster-admin.pem";
      };
      "cluster-admin-key.pem" = {
        sopsFile = ../../../hosts/vm403bfeq/services/kubernetes/certificates.yaml;
        path = "/home/nicoswan/.kube/cygnus-labs-kubernetes-cluster-admin-key.pem";
      };
    };
  };

  # 
  # SSH configuration
  # 
  # programs.ssh = {

  #   matchBlocks = {
  #     "gitlab" = {
  #       host = "gitlab.com";
  #       identitiesOnly = true;
  #       identityFile = [
  #         "~/.ssh/id_gitlab-key"
  #       ];
  #     };

  #     "102.135.163.95" = {
  #       host = "102.135.163.95";
  #       identitiesOnly = true;
  #       identityFile = [
  #         "~/.ssh/id_nicoswan"
  #         "~/.ssh/vm403bfeq"
  #       ];
  #     };

  #     "github" = {
  #       host = "github.com";
  #       identitiesOnly = true;
  #       identityFile = [
  #         "~/.ssh/id_nicoswan"
  #       ];
  #     };
  #   };
  # };


}
