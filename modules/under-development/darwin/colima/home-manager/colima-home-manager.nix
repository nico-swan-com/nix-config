{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.colima;

  networkType = lib.types.submodule {



    #   activate set as active Docker/Kubernetes context on startup (default true)
    #   - a, --arch string                 architecture (aarch64, x86_64) (default "aarch64")
    # -c, --cpu int                     number of CPUs (default 2)
    # --cpu-type string             the CPU type, options can be checked with 'qemu-system-aarch64 -cpu help'
    # -d, --disk int                    disk size in GiB (default 60)
    # -n, --dns ipSlice                 DNS resolvers for the VM (default [])
    # --dns-host strings            custom DNS names to provide to resolver
    # -e, --edit                        edit the configuration file before starting
    # --editor string               editor to use for edit e.g. vim, nano, code (default "$EDITOR" env var)
    # --env stringToString          environment variables for the VM (default [])
    # -f, --foreground                  Keep colima in the foreground
    # -h, --help                        help for start
    # --hostname string             custom hostname for the virtual machine
    # --k3s-arg strings             additional args to pass to k3s (default [--disable=traefik])
    # -k, --kubernetes                  start with Kubernetes
    # --kubernetes-version string   must match a k3s version https://github.com/k3s-io/k3s/releases (default "v1.30.0+k3s1")
    # -m, --memory int                  memory in GiB (default 2)
    # -V, --mount strings               directories to mount, suffix ':w' for writable
    # --mount-inotify               propagate inotify file events to the VM (default true)
    # --mount-type string           volume driver for the mount (sshfs, 9p, virtiofs) (default "sshfs")
    # --network-address             assign reachable IP address to the VM
    # -r, --runtime string              container runtime (containerd, docker) (default "docker")
    # -s, --ssh-agent                   forward SSH agent to the VM
    # --ssh-config                  generate SSH config in ~/.ssh/config (default true)
    # -t, --vm-type string              virtual machine type (qemu, vz) (default "qemu")
    # --vz-rosetta                  enable Rosetta for amd64 emulation


    options = {
      address = mkOption {
        description = "Assign reachable IP address to the VM";
        type = types.bool;
        default = true;
      };

      dns = mkOption {
        description = "The DNS servers to use.";
        type = types.listOf types.str;
        default = [ "8.8.8.8" "1.1.1.1" ];
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
      hostname = mkOption {
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

  command =

    startScript = vm: pkgs.writeScriptBin "start-colima-${vm.hostname}.sh" ''
    export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/run/current-system/sw/bin"
    
    function shutdown() {
      ${pkgs.colima}/bin/colima stop ${vm.hostname}
      if [ $? -eq 0 ]; then
        echo "Colima instance ${vm.hostname} stopped successfully."
      fi
      
      exit 0
    }

    trap shutdown SIGTERM
    trap shutdown SIGINT

    # wait until colima is running
    while true; do
      ${pkgs.colima}/bin/colima -p ${vm.hostname} status &>/dev/null
      if [ $? -eq 0 ]; then
        break
      fi

      ${command}
      sleep 5
    done

    tail -f /dev/null &
    wait $!
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

    # home.file = lib.mkMerge (map
    #   (vm: {
    #     ".colima/_templates/default.yaml".text = builtins.readFile (configFile vm);
    #   })
    #   cfg.vms);

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
                "${startScript}"
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
