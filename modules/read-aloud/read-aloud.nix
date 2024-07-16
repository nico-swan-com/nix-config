{ config, lib, pkgs, ... }:

with lib;

let
  normalUsers = builtins.filter (x: x.isNormalUser) config.users.users; 

  cfg = config.gnome-read-aloud;

  gnome-settings =
    let
      inherit (builtins) length head tail listToAttrs genList;
      range = a: b: if a < b then [ a ] ++ range (a + 1) b else [ ];
      globalPath = "org/gnome/settings-daemon/plugins/media-keys";
      path = "${globalPath}/custom-keybindings";
      mkPath = id: "${globalPath}/custom-keybindings/cygnus-labs/custom${toString id}";
      isEmpty = list: length list == 0;
      mkSettings = settings:
        let
          checkSettings = { name, command, binding }@this: this;
          aux = i: list:
            if isEmpty list then [ ] else
            let
              hd = head list;
              tl = tail list;
              name = mkPath i;
            in
            aux (i + 1) tl ++ [{
              name = mkPath i;
              value = checkSettings hd;
            }];
          settingsList = (aux 0 settings);
        in
        listToAttrs (settingsList ++ [
          {
            name = "${globalPath}";
            value = {
              custom-keybindings = genList (i: "/${mkPath i}/") (length settingsList);
            };
          }
        ]);
    in
    mkSettings [
      {
        name = "read-aloud";
        command = "read-aloud";
        binding = "<Control>Escape";
      }
    ];
in
{

  options = {
    gnome-read-aloud = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable read-aloud.
        '';
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = null;
      };

      package = mkOption {
        type = types.package;
        default = pkgs.read-aloud;
        defaultText = "pkgs.read-aloud";
        description = ''
          Read-aloud package to use.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    programs.dconf.enable = true;

    home-manager.users."${config.gnome-read-aloud.user}" = { lib, ... }: {
      dconf.settings = with lib.gvariant; gnome-settings; 
    };
  };
}
