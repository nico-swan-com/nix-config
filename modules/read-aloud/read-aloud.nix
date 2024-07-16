{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.read-aloud;
in
{
  options = {
    services.howdy = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable howdy and PAM module for face recognition.
        '';
      };

    #   package = mkOption {
    #     type = types.package;
    #     default = pkgs.howdy;
    #     defaultText = "pkgs.howdy";
    #     description = ''
    #       Howdy package to use.
    #     '';
    #   };

    #   device = mkOption {
    #     type = types.path;
    #     default = "/dev/video0";
    #     description = ''
    #       Device file connected to the IR sensor.
    #     '';
    #   };

    #   certainty = mkOption {
    #     type = types.int;
    #     default = 4;
    #     description = ''
    #       The certainty of the detected face belonging to the user of the account. On a scale from 1 to 10, values above 5 are not recommended.
    #     '';
    #   };

    #   dark-threshold = mkOption {
    #     type = types.int;
    #     default = 50;
    #     description = ''
    #       Because of flashing IR emitters, some frames can be completely unlit. Skip the frame if the lowest 1/8 of the histogram is above this percentage of the total. The lower this setting is, the more dark frames are ignored.
    #     '';
    #   };
    # };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
