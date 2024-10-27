{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.cygnus-labs.gitlab;
in
{


  options.services.cygnus-labs.gitlab = {
    enable = mkEnableOption "Enable gitlab.";
  };

  config = mkIf cfg.enable {

  

  };
}