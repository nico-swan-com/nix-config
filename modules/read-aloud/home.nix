{ lib, pkgs, config, ... }:
let 
normalUsers = builtins.filter (x: x.isNormalUser) config.users.users; 


in
{
  imports = [
    <home-manager/nixos>
  ];

  # Declaring option types
  options = {
    gnome-read-aloud = {
      enable = lib.mkEnableOption "Enable GNOME read-aloud";

      user = lib.mkOption {
        type = lib.types.str;
        default = null;
      };

      keybindings = lib.mkOption {
        type = lib.types.attrs;
        default = null;
      };

    };
  };

  config = lib.mkIf config.gnome-read-aloud.enable {
    programs.dconf.enable = true;

    home-manager.users."${config.gnome-read-aloud.user}" = { lib, ... }: {
      home.stateVersion = "24.05";

      dconf.settings = {
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
            name = "read-aloud";
            command = "read-aloud";
            binding = "<Control>Escape";
          };

          "org/gnome/settings-daemon/plugins/media-keys" = {
            custom-keybindings = [
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
            ];
          };
      };

    };
  };
}
