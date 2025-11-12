{ pkgs, inputs, ... }:
let
  gitProjectUpdaterPkg =
    inputs.git-project-updater.packages.${pkgs.system}.default;
in {
  imports = [
    ../../../../common/home-manager/desktop/common-desktop.nix
    ../../../../common/home-manager/terminal/lazygit.nix
    ../../../../common/home-manager/neovim.nix
    ../../../../common/home-manager/development/github.nix
    ../../../../common/home-manager/desktop/applications/vscode/vscode.nix
    ../../../../common/home-manager/development/node/node_20.nix
    ../../../../common/home-manager/desktop/applications/lens.nix
    ../../../../common/home-manager/desktop/applications/google-chrome.nix
    ../../../../common/home-manager/terminal/fun.nix
    ./rclone.nix
  ];

  programs.nicoswan = {
    utils.kubernetes = {
      enable = true;
      additional-utils = true;
      admin-utils = true;
    };
  };

  programs.zsh = {
    shellAliases = { nv = "NVIM_APPNAME=LazyVim nvim"; };
    initContent = ''
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
      discord
      postman
      bottles

      blender
      gimp
      flameshot
      rust-analyzer
      playwright
      playwright-test
      affine
    ] ++ (with pkgs.unstable; [
      devenv
      lunarvim
      cryptomator
      nest-cli
      libreoffice
      protonvpn-gui
      opentofu
      code-cursor
      obsidian
      ollama
      zed-editor

      shotcut
    ]) ++ (with pkgs.stable; [ beekeeper-studio  rpi-imager ]);

  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Print>";
      command = "/home/nicoswan/bin/screenshot.sh";
      name = "Screenshot";
    };
  };

  # Systemd user service to ensure keybinding is set after GNOME starts
  # This runs after login and ensures the keybinding persists across reboots
  # The issue is that GNOME might reset dconf settings on startup, so we re-apply them
  systemd.user.services.set-screenshot-keybinding = {
    Unit = {
      Description = "Set screenshot keybinding after GNOME starts";
      After = [ "graphical-session.target" ];
      Wants = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "set-screenshot-keybinding" ''
        # Wait for GNOME settings daemon to be ready
        sleep 3
        
        # Ensure dconf database is accessible
        export XDG_RUNTIME_DIR="/run/user/$(id -u)"
        export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
        
        # Set the custom keybinding using dconf
        ${pkgs.dconf}/bin/dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
        ${pkgs.dconf}/bin/dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/name "'Screenshot'"
        ${pkgs.dconf}/bin/dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/command "'/home/nicoswan/bin/screenshot.sh'"
        ${pkgs.dconf}/bin/dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/binding "'<Print>'"
      '';
    };
    Install.WantedBy = [ "default.target" ];
  };

}
