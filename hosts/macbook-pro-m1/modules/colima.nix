{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.colima;

  networkType = lib.types.submodule {
    options = {
      address = mkOption {
        description = "Assign reachable IP address to the VM";
        type = types.bool;
        default = true;
      };

      dns = mkOption {
        description = "The DNS servers to use.";
        type = types.listOf types.str;
        default = [ "8.8.8.8" "192.168.3.11" ];  
      };
       
      dnsHosts = mkOption {
         description = "DNS hostnames to resolve to custom targets using the internal resolver.";
         type = types.attrsOf types.attrs;
         default = { };
      };

    };
  };

  kubernetesType = lib.types.submodule {
    options = {
      enabled = mkOption {
        description = "Enable kubernetes";
        type = types.bool;
        default = false;
      };

      version = mkOption {
        description = "Kubernetes version to use.";
        type = types.str;
        default = "latest";
      };

      k3sArgs = mkOption {
        description = "Additional args to pass to k3s.";
        type = types.listOf types.str;
        default = [ ];
      };
    };
  };

  vmConfigType = lib.types.submodule {
    options = {
      hostname  = mkOption {
        description = "The hostname of the colima instance.";
        type = types.str;
        default = "default";
      };

      enable = mkOption {
        description = "Enable the VM";
        type = types.bool;
        default = true;
      };

      cpu = mkOption {
        description = "The number of CPUs to allocate.";
        type = types.nullOr types.int;
        example = 4;
        default = 2;
      };

      memory = mkOption {
        description = "The amount of memory to allocate.";
        type = types.nullOr types.int;
        example = 8;
        default = 2;
      };

      disk = mkOption {
        description = "The amount of disk space to allocate.";
        type = types.nullOr types.int;
        example = 1;
        default = 60;
      };

      arch = mkOption {
        description = "The architecture to use.";
        type = types.enum [ "x86_64" "aarch64" ];
        default = "aarch64";
      };

      runtime = mkOption {
        description = "The container runtime to use. default is docker";
        type = types.enum [ "containerd" "docker" ];
        example = "containerd";
        default = "docker";
      };

      autoActivate = mkOption {
        description = "Auto-activate on the Host for client access.";
        type = types.bool;
        default = true;
      };

      kubernetes = mkOption {
        description = "Kubernetes configuration for the virtual machine.";
        type = kubernetesType;
        default = { };
      };

      network = mkOption {
        description = "Network configurations for the virtual machine.";
        type = networkType;
        default = { };
      };

      forwardAgent = mkOption {
        description = "Forward the host's SSH agent to the virtual machine.";   
        type = types.bool;
        default = false;
      };

      docker = mkOption {
        description = "Docker daemon configuration that maps directly to daemon.json.";
        type = types.attrsOf types.attrs;
        default = { };
      };

      vmType = mkOption {
        description = "Virtual Machine type (qemu, vz)";
        type = types.str;
        default = "qemu";
      };

      rosetta = mkOption {
        description = "Utilise rosetta for amd64 emulation (requires m1 mac and vmType `vz`)";
        type = types.bool;
        default = false;
      };

      mountType = mkOption {
        description = "Volume mount driver for the virtual machine (virtiofs, 9p, sshfs).";
        type = types.str;
        default = "sshfs";
      };

      mountInotify = mkOption {
        description = "Propagate inotify file events to the VM.";
        type = types.bool;
        default = false;
      };

      cpuType = mkOption {
        description = "The CPU type for the virtual machine (requires vmType `qemu`).";
        type = types.str;
        default = "host";
      };

      provision = mkOption {
        description = "Custom provision scripts for the virtual machine.";
        type = types.listOf (types.attrsOf types.attrs);
        default = [ ];
      };  

      sshConfig = mkOption {
        description = "Modify ~/.ssh/config automatically to include a SSH config for the virtual machine.";
        type = types.bool;
        default = true;
      };

      mounts = mkOption {
        description = "Configure volume mounts for the virtual machine.";
        type = types.listOf (types.attrsOf types.attrs);
        default = [ ];
      };

      env = mkOption {
        description = "Environment variables for the virtual machine.";
        type = types.attrsOf types.str;
        default = { };
      };
    };
  };

  generateConfigFile = vm: pkgs.runCommand "${vm.hostname}.yaml" { } ''
    echo ${builtins.toJSON vm} | ${pkgs.remarshal}/bin/json2yaml -o $out
  '';

  configJSON = vm: pkgs.writeText "${vm.hostname}.json" (builtins.toJSON vm);
  configFile = vm: pkgs.runCommand "${vm.hostname}.yaml" { } ''
    ${pkgs.remarshal}/bin/json2yaml -i ${configJSON vm} -o $out
  '';

in
{
  options.services.colima = {
    enable = mkEnableOption "Colima with VMs";

    vms = mkOption {
      description = "VM configurations.";
      type = types.listOf vmConfigType;
    };

  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; mkIf (cfg.vms != [ ]) [
      qemu
      colima
      lima
    ];

    home.file = lib.mkMerge (map
      (vm: {
        ".colima/_templates/default.yaml".text = builtins.readFile (configFile vm);
      })
      cfg.vms);

    launchd = {
      enable = true;
      agents = lib.mkMerge (map
        (vm: {
          "${vm.hostname}" = {
            enable = vm.enable;
            config = {
              ProgramArguments = [
                "${pkgs.bash}/bin/bash"
                "-l"
                "-c"
                "${pkgs.colima}/bin/colima start -p ${vm.hostname}"
              ];
              StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/colima-${vm.hostname}.stderr.log";
              StandardOutPath = "${config.home.homeDirectory}/Library/Logs/colima-${vm.hostname}.stdout.log";
              RunAtLoad = true;
              KeepAlive = true;
              EnableTransactions = true;
            };
          };
        })
        cfg.vms);
    };
  };
}