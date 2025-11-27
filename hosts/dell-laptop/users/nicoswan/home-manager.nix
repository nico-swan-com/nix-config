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
      

      blender
      gimp
      flameshot
      rust-analyzer
      playwright
      playwright-test
      kubelogin-oidc
    ] ++ (with pkgs.unstable; [
      devenv
      lunarvim
      cryptomator
      nest-cli
      libreoffice
      protonvpn-gui
      #opentofu
      code-cursor
      obsidian
      ollama
      zed-editor

      shotcut
      bottles
    ]) ++ (with pkgs.stable; [ beekeeper-studio rpi-imager ]);

  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/cygnus-labs/custom0/"
      ];
    };
    # Screenshot keybinding
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Print>";
      command = "/home/nicoswan/bin/screenshot.sh";
      name = "Screenshot";
    };
    # Read-aloud keybinding
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/cygnus-labs/custom0" = {
      binding = "<Control>Escape";
      command = "read-aloud --voice=/home/nicoswan/.local/share/read-aloud/voices/en_US-joe-medium.onnx";
      name = "Read aloud";
    };
  };

  # Systemd user service to ensure keybinding is set after GNOME fully initializes
  # This runs after login and ensures the keybinding persists across reboots
  # Using gsettings which is the proper way to set GNOME settings
  systemd.user.services.set-screenshot-keybinding = {
    Unit = {
      Description = "Set screenshot keybinding after GNOME starts";
      After = [ "org.gnome.SettingsDaemon.MediaKeys.target" "graphical-session.target" ];
      Wants = [ "org.gnome.SettingsDaemon.MediaKeys.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "set-screenshot-keybinding" ''
        # Wait for GNOME to be fully initialized
        sleep 5
        
        # Ensure environment is set
        export XDG_RUNTIME_DIR="/run/user/$(id -u)"
        export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
        
        # Use gsettings to set both keybindings (more reliable than dconf for GNOME)
        ${pkgs.glib}/bin/gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/cygnus-labs/custom0/']"
        
        # Screenshot keybinding
        ${pkgs.glib}/bin/gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "'Screenshot'"
        ${pkgs.glib}/bin/gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "'/home/nicoswan/bin/screenshot.sh'"
        ${pkgs.glib}/bin/gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "'<Print>'"
        
        # Read-aloud keybinding
        ${pkgs.glib}/bin/gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/cygnus-labs/custom0/ name "'Read aloud'"
        ${pkgs.glib}/bin/gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/cygnus-labs/custom0/ command "'read-aloud --voice=/home/nicoswan/.local/share/read-aloud/voices/en_US-joe-medium.onnx'"
        ${pkgs.glib}/bin/gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/cygnus-labs/custom0/ binding "'<Control>Escape'"
        
        # Also set using dconf as backup
        ${pkgs.dconf}/bin/dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/cygnus-labs/custom0/']"
        
        # Screenshot
        ${pkgs.dconf}/bin/dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/name "'Screenshot'"
        ${pkgs.dconf}/bin/dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/command "'/home/nicoswan/bin/screenshot.sh'"
        ${pkgs.dconf}/bin/dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/binding "'<Print>'"
        
        # Read-aloud
        ${pkgs.dconf}/bin/dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/cygnus-labs/custom0/name "'Read aloud'"
        ${pkgs.dconf}/bin/dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/cygnus-labs/custom0/command "'read-aloud --voice=/home/nicoswan/.local/share/read-aloud/voices/en_US-joe-medium.onnx'"
        ${pkgs.dconf}/bin/dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/cygnus-labs/custom0/binding "'<Control>Escape'"
      '';
    };
    Install.WantedBy = [ "default.target" ];
  };

}
