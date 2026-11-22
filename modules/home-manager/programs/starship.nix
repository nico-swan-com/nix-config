{ config, lib, ... }:
with lib;
let
  cfg = config.programs.nicoswan.starship;
in
{

  options.programs.nicoswan.starship = {
    enable = mkEnableOption "Nico Swan starship default shell decorator setup.";
  };

  config = mkIf cfg.enable {
    programs = {
      starship = {
        enable = true;
        settings = {
          add_newline = true;
          docker_context.disabled = true;
          aws.disabled = true;
          line_break.disabled = false;
          command_timeout = 1000;

          # Do not override symbols here: custom glyphs were Nerd Fonts v2
          # codepoints and render as blanks with nerd-fonts 3.x. Starship's
          # defaults are Nerd Fonts v3 compatible.
        };
      };
    };
  };
}
