{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.services.docker-compose.example;
  dockerComposeFile = pkgs.writeText "docker-compose.yaml" ''
    version: '3.8'
    services:
      app:
        image: 'jc21/nginx-proxy-manager:latest'
        restart: unless-stopped
        ports:
          - '80:80' # Public HTTP Port
          - '443:443' # Public HTTPS Port
          - '81:81' # Admin Web Port
        volumes:
          - /Users/Nico.Swan/tmp/docker/data:/data
          - /Users/Nico.Swan/tmp/docker/letsencrypt:/etc/letsencrypt
   '';
   dockerStartScript = pkgs.writeScript "dockerStartScript" ''
      ${pkgs.docker-compose}/bin/docker-compose -f ${dockerComposeFile} up
   '';
in
{
  options.services.docker-compose.example = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable the local admin api service.";
    };
  };

  config = mkIf cfg.enable {
  
  launchd = {
      enable = true;
      agents = {
        "docker-compose-example" = {
          enable = true;
          config = {
            ProgramArguments = [
              "${pkgs.bash}/bin/bash"
              "-l"
              "-c"
              "${dockerStartScript}"
            ];
            UserName = "Nico.Swan";
            Label = "docker.example.service";
            StandardErrorPath = "/Users/Nico.Swan/Library/Logs/docker-compose-example.stderr.log";
            StandardOutPath = "/Users/Nico.Swan/Library/Logs/docker-compose-example.stdout.log";
            RunAtLoad = true;
            KeepAlive = true;
            EnableTransactions = false;
            EnvironmentVariables = {
              PATH = "${pkgs.docker}/bin:${pkgs.docker-compose}/bin";
            };
          };
        };
      };
    };
  };

}
