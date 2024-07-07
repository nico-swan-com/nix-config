{ pkgs, ... }:
{

  imports = [
    ./common.nix

    # Terminal applictions
    ../../common/optional/terminal/lazygit.nix # Git UI
    ../../common/optional/terminal/lunarvim.nix # VIM IDE
    #../../common/optional/terminal/termscp.nix # Terminal scure copy

  ];

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
