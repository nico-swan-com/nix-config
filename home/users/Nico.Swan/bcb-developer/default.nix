{ inputs, config, pkgs, configVars, ... }:
{

  imports = [
    ./ssh.nix
    ../../../common/optional/terminal/lazygit.nix
    ../../../common/optional/desktop/terminals
    ../../../common/optional/terminal/lunarvim.nix
    ../../../common/optional/development/node/node_20.nix
    ../../../common/optional/fun.nix
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

  home.packages = with pkgs; [
    terminal-notifier
    kail
    ktop
    dooit
  ];

  programs.nnn.bookmarks =
    {
      D = "~/Documents";
      d = "~/Developer/src";
      h = "~/";
    };


  programs.zsh = {
    shellAliases = {
      # Database
      db_prod = "cloud_sql_proxy -enable_iam_login -instances=bcb-group:europe-west2:bcb-production=tcp:3307,bcb-group:europe-west2:bcb-pg1=tcp:15432";
      db_sandbox = "cloud_sql_proxy -enable_iam_login -instances=bcb-group-sandbox:europe-west2:bcb-pg1=tcp:15432,bcb-group-sandbox:europe-west2:sandbox=tcp:3307";

      # Development
      nstart = "nest start --watch";
      dstart = "nest start --watch --debug";
      ngs = "ng serve";
      kube-sandbox-context = "kubectl config use-context gke_bcb-group-sandbox_europe-west2_sandbox";
      ksandbox = "kubectl --context gke_bcb-group-sandbox_europe-west2_sandbox -n sandbox";

    };



    sessionVariables = {
      NVM_DIR = "$HOME/.nvm";
    };

    # This is added for when you have nvm install via homebrew
    # Also the manual install for iterm2
    initExtra = ''
      [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
      [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

      test -e "~/.iterm2_shell_integration.zsh" && source "~/.iterm2_shell_integration.zsh"

      klogs-sandbox () {
        pod = "$(kubectl --context gke_bcb-group-sandbox_europe-west2_sandbox -n sandbox get po -o wide|tail -n+2|fzf -n1 --reverse --tac --preview='kubectl --context gke_bcb-group-sandbox_europe-west2_sandbox -n sandbox logs --tail=20 --all-containers=true {1} |jq' --preview-window=down:50%:hidden --bind=ctrl-p:toggle-preview --header="^P: Preview Logs "|awk '{print $1}' | jq)"
          if [[ -n $pod ]];
          then
            kubectl --context gke_bcb-group-sandbox_europe-west2_sandbox logs --all-containers = true $pod
          fi
      }


    '';
  };



}
