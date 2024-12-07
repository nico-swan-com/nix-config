{ pkgs, inputs, config, ... }:
{

  #Import your own custom modules
  imports = [
    # Core
    ./home-manager/sops.nix # Setup up user level secrets
    ./home-manager/dot-npmrc.nix # Setup your developer .npmrc file

    # Optional Desktop Applications
    ./home-manager/desktop

    ./home-manager/custom-zsh-functions.nix # Custom zsh functions

  ];

  fonts.fontconfig.enable = true;

  # Install addition packages via home manager
  home.packages = with pkgs.unstable; [
    process-compose
    # openapi-tui # seems to not work with files
  ] ++ (with pkgs; [
    sops
    lunarvim
    vimPlugins.neogit


    # Utils
    lazydocker # Terninal UI for docker
    podman-tui # Podman terminal UI
    portal # Copy files
    sshs # SSH session manager

    # Productivity tools
    slides
    visidata
    glow # Terminal marckdown viewer

    # Development
    devenv # development environments
    git-extras
    nodejs_20 # Node 20 (setup as default)
    nodePackages.npm-check-updates # ncu updater for node packages in projects
    atac # Postman for the terminal

    # Fonts
    fira-code-nerdfont # Font installation
    noto-fonts
    meslo-lgs-nf

    #ceryx
    # Network security
    termshark

    # AI
    oterm

  ]);

  programs.nnn.bookmarks = {
    D = "~/Documents";
    d = "~/Developer/src";
    h = "~/";
  };

  programs.zsh = {
    shellAliases = {
      dev = "cd ~/Developer/src";
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
      export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt

      [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
      [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

      test -e "~/.iterm2_shell_integration.zsh" && source "~/.iterm2_shell_integration.zsh"
    '';
  };
}
