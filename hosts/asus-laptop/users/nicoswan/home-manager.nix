{ pkgs, configLib, ... }: {

  imports = [
    ../../../../common/home-manager/desktop/common-desktop.nix

    # Terminal applictions
    ../../../../common/home-manager/terminal/lazygit.nix # Git UI
    #../../../../common/home-manager/development/lunarvim # VIM IDE
    #../../../../common/home-manager/development/neovim # NEOVIM IDE
    #../../../../common/home-manager/development/nixvim # NEOVIM IDE
    ../../../../common/home-manager/neovim.nix

    # Software Development
    ../../../../common/home-manager/development/github.nix
    #../../../../common/home-manager/desktop/applications/vscode/vscode.nix
    ../../../../common/home-manager/development/node/nodejs.nix

    # Desktop application
    #../../../../common/home-manager/desktop/applications/lens.nix
    #../../../../common/home-manager/desktop/applications/firefox.nix
    ../../../../common/home-manager/desktop/applications/google-chrome.nix

    #../../../../common/home-manager/desktop/applications/libraoffice.nix
    #../../../../common/home-manager/desktop/applications/obsidian.nix

    # Just for fun
    ../../../../common/home-manager/terminal/fun.nix
  ];

  programs.nicoswan = {
    ai-agents = {
      enable = true;
      exposeOnLan = true;
      paperclip.allowedHostnames = [
        "localhost"
        "127.0.0.1"
        "asus-laptop"
        "asus-laptop.local"
        "asus-laptop.nicoswan.com"
      ];
    };
    utils.google-cloud-sdk.enable = false;
    utils.kubernetes = {
      enable = false;
      additional-utils = false;
      admin-utils = false;
    };
  };
  # Install addition packages via home manager
  home.packages =
    with pkgs;
    [
      systemctl-tui
      # Some fun
      lnav
      #lunarvim
      openssl
      sshs
      # Local overlay package (not on nixpkgs-unstable)
      grok-bot
    ]
    ++ (with pkgs.unstable; [
      code-cursor
    ]);

  # home = {
  #   file.".kube/cygnus-labs-kubernetes-ca.pem".source = "${config.sops.secrets."ca.pem".path}";
  # };

}
