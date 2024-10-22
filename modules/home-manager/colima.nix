{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.colima;
in
{
  options.services.colima = {
    enable = mkEnableOption "Colima with VMs";

    vms = lib.mkOption {
      description = "List of VM configurations.";
      default = [ ];
      type = lib.types.listOf (lib.types.attrsOf {
        name = mkOption {
          description = "The name of the colima instance.";
          type = types.str;
          default = "default";
        };

        runAs = mkOption {
          description = "The mac username to use to user for luanchd.";
          type = types.str;
        };

        cpu = mkOption {
          description = "The number of CPUs to allocate. default is 2";
          type = types.nullOr types.int;
          example = 4;
          default = null;
        };

        memory = mkOption {
          description = "The amount of memory to allocate. default is 2GB";
          type = types.nullOr types.int;
          example = 8;
          default = null;
        };

        disk = mkOption {
          description = "The amount of disk space to allocate. default is 60GB";
          type = types.nullOr types.int;
          example = 1;
          default = null;
        };

        dns = mkOption {
          description = "The DNS servers to use.";
          type = types.listOf types.str;
          default = [ "8.8.8.8" "1.1.1.1" ];
          example = "[\"8.8.8.8\" \"1.1.1.1\"]";
        };

        arch = mkOption {
          description = "The architecture to use.";
          type = types.enum [ "x86_64" "aarch64" ];
          default = "aarch64";
        };

        kubernetes = mkOption {
          description = "Enable kubernetes";
          type = types.bool;
          default = false;
        };

        assignIp = mkOption {
          description = "Assign reachable IP address to the VM";
          type = types.bool;
          default = true;
        };

        mount = mkOption {
          description = "The mount point to use.";
          type = types.listOf types.str;
          default = [ ];
          example = "[\"<path on the host>:<path visible to Docker>[:w]\"]";
        };

        k3s-arg = mkOption {
          description = "The k3s arguments to use.";
          type = types.listOf types.str;
          default = [ ];
          example = "[\"--no-deploy=traefik\"]";
        };

        kubernetes-disable = mkOption {
          description = "The kubernetes components to disable.";
          type = types.listOf types.str;
          default = [ ];
          example = "[\"coredns\" \"servicelb\" \"traefik\" \"local-storage\" \"metrics-server\"]";
        };

        runtime = mkOption {
          description = "The container runtime to use. default is docker";
          type = types.enum [ "containerd" "docker" ];
          example = "containerd";
          default = "docker";
        };

      });
    };

    package = mkPackageOption pkgs "colima" { };

  };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; mkIf (cfg.vms != [ ]) [
      qemu
      colima
      lima
    ];

    # Generate the colima.yaml file and save it to the user's .config folder
    systemd.user.services.colima-write-config =
      let
        config = {
          name = "name";
        };
        settingsFormat = pkgs.formats.yaml { };
        settingsFile = settingsFormat.generate "colima.yaml" config;


      in
      {
        description = "Write colima.yaml configuration file";
        serviceConfig = {
          ExecStart = "${pkgs.writeText "colima.yaml" settingsFile} > ${config.home.homeDirectory}/.config/colima.yaml";
          Restart = "on-failure";
        };
        wantedBy = [ "default.target" ];
      };

  };
}
