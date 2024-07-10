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

  home.packages = with pkgs; [
    terminal-notifier
  ];

  programs.zsh = {
    shellAliases = {
      # Database
      db_prod = "cloud_sql_proxy -enable_iam_login -instances=bcb-group:europe-west2:bcb-production=tcp:3307,bcb-group:europe-west2:bcb-pg1=tcp:15432";
      db_sandbox = "cloud_sql_proxy -enable_iam_login -instances=bcb-group-sandbox:europe-west2:bcb-pg1=tcp:15432,bcb-group-sandbox:europe-west2:sandbox=tcp:3307";

      # Development
      nstart = "nest start --watch";
      dstart = "nest start --watch --debug";
      ngs = "ng serve";

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
    '';
  };
}
