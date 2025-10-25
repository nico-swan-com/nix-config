{ pkgs, inputs, ... }:
let
  gitProjectUpdaterPkg =
    inputs.git-project-updater.packages.${pkgs.system}.default;
in {
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
    ../../../../common/home-manager/desktop/applications/vscode/vscode.nix
    ../../../../common/home-manager/development/node/node_20.nix

    # Desktop application
    ../../../../common/home-manager/desktop/applications/lens.nix
    #../../../../common/home-manager/desktop/applications/firefox.nix
    ../../../../common/home-manager/desktop/applications/google-chrome.nix

    #../../../../common/home-manager/desktop/applications/libraoffice.nix
    #../../../../common/home-manager/desktop/applications/obsidian.nix

    # Just for fun
    ../../../../common/home-manager/terminal/fun.nix

    ./rclone.nix
  ];

  programs.nicoswan = {
    utils.google-cloud-sdk.enable = true;
    utils.kubernetes = {
      enable = true;
      additional-utils = true;
      admin-utils = true;
    };
  };

  programs.zsh = {
    shellAliases = { nv = "NVIM_APPNAME=LazyVim nvim"; };
    initContent = ''
      #set-github-access-token

      function nvims() {
        items=("default" "kickstart" "LazyVim" "NvChad" "AstroNvim")
        config=$(printf "%s\n" "\$\{items[\@]}" | fzf --prompt=" Neovim Config  " --height=~50% --layout=reverse --border --exit-0)
        if [[ -z $config ]]; then
          echo "Nothing selected"
          return 0
        elif [[ $config == "default" ]]; then
          config=""
        fi
        NVIM_APPNAME=$config nvim $@
      }
      #bindkey -s ^a "nvims\n"

    '';
  };

  # Install addition packages via home manager
  home.packages = with pkgs;
    [
      (writeShellScriptBin "set-github-access-token"
        (builtins.readFile ../../scripts/set-github-access-token.sh))
      (writeShellScriptBin "tmux-cycle-windows"
        (builtins.readFile ../../../../common/scripts/tmux-cycle-windows.sh))
      (writeShellScriptBin "tmux-dashboard"
        (builtins.readFile ../../../../common/scripts/tmux-dashboard.sh))

      gitProjectUpdaterPkg
      systemctl-tui
      gnome-extensions-cli
      cmatrix # Some fun
      glow # Terminal marckdown viewer
      lnav
      openssl
      mattermost-desktop
      discord
      postman
      bottles

      blender
      gimp
      flameshot
      rust-analyzer
      playwright
      playwright-test
    ] ++ (with pkgs.unstable; [
      devenv
      lunarvim
      cryptomator
      nest-cli
      libreoffice
      protonvpn-gui
      opentofu
      vcluster
      code-cursor
      obsidian
      ollama
      zed-editor

      shotcut
    ]) ++ (with pkgs.stable; [ beekeeper-studio  rpi-imager ]);

  # home = {
  #   file.".kube/cygnus-labs-kubernetes-ca.pem".source = "${config.sops.secrets."ca.pem".path}";
  # };
  # /home/nicoswan/bin/screenshot.sh
  #
  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/screenprint/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/screenprint" =
      {
        binding = "<Print>";
        command = "/home/nicoswan/bin/screenshot.sh";
        name = "Screen capture";
      };
  };

}
