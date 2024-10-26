{ config, lib, pkgs, ... }:

with lib;

let
  
  cfg = config.gnome-read-aloud;

  
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

      model-config = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = ''
          The path to the model config json which can be downloaded from Huggingface
          https://huggingface.co/rhasspy/piper-voices/tree/main

          The default is en_US/joe/medium/en_US-joe-medium.onnx.json
        '';
      };

      model-voice = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = ''
          The path to the model file which can be downloaded from Huggingface
          https://huggingface.co/rhasspy/piper-voices/tree/main

          The default is en_US/joe/medium/en_US-joe-medium.onnx
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
