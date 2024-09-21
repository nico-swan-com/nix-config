{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.colima-vm;
in
{
  options.services.colima-vm = {
    enable = mkEnableOption "Colima with VM";

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
      default = [ "8.8 .8 .8" "1.1 .1 .1" ];
      example = "[\"8.8.8.8\" \"1.1.1.1\"]";
    };

    arch = mkOption {
      description = "The architecture to use.";
      type = types.enum [ "x86_64" "aarch64" ];
      default = "aarch64";
    };

    hostname = mkOption {
      description = "The hostname to use.";
      type = types.str;
      default = "kubernetes-cluster";
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

    package = mkPackageOption pkgs "colima-vm" { };

  };

  config = mkIf cfg.enable rec {

    environment.systemPackages = with pkgs; [
      colima
      qemu
      lima
    ];

    # environment.variables = {
    #   COLIMA_VM="default";
    #   #COLIMA_VM_SOCKET="$HOME/.colima/$COLIMA_VM/docker.sock";
    #   #DOCKER_HOST="unix://$COLIMA_VM_SOCKET";  
    # };

    launchd.daemons."colima-${cfg.name}" =
      let
        kubernetes = lib.optionalString (cfg.cpu == true) " --kubernetes";
        cpu = lib.optionalString (cfg.cpu != null) " --cpu ${toString cfg.cpu}";
        memory = lib.optionalString (cfg.memory != null) " --memory ${toString cfg.memory}";
        disk = lib.optionalString (cfg.disk != null) " --disk ${toString cfg.disk}";
        mount = " ${lib.concatStringsSep " " (builtins.map (mount: "--mount ${mount}") cfg.mount)}";
        dns = " ${lib.concatStringsSep " " (builtins.map (ip: "--dns ${ip}") cfg.dns)}";
        k3sArg = "[${lib.concatStringsSep " " (builtins.map (config: "${config}") cfg.k3s-arg)}]";
        kubernetesDisable = "${lib.concatStringsSep "," (builtins.map (config: "${config}") cfg.kubernetes-disable)}";

        command = ''${pkgs.colima}/bin/colima start -p "${cfg.name}"${kubernetes} --arch "${cfg.arch}" --kubernetes-disable=${kubernetesDisable} --hostname "${cfg.hostname}" --network-address=${toString cfg.assignIp} --runtime "${cfg.runtime}" --k3s-arg=${k3sArg}${mount}${cpu}${memory}${disk}
        '';
      in
      {

        script = ''
          export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/run/current-system/sw/bin"

          function shutdown() {
            ${pkgs.colima}/bin/colima stop ${cfg.name}
            if [ $? -eq 0 ]; then
              echo "Colima instance ${cfg.name} stopped successfully."
            fi
          
            exit 0
          }

          trap shutdown SIGTERM
          trap shutdown SIGINT

          # wait until colima is running
          while true; do
            ${pkgs.colima}/bin/colima -p ${cfg.name} status &>/dev/null
            if [ $? -eq 0 ]; then
              break
            fi

            ${command}
            sleep 5
          done

          tail -f /dev/null &
          wait $!
        '';

        serviceConfig = {
          UserName = "${cfg.runAs}";
          KeepAlive = false;
          RunAtLoad = true;
          EnableTransactions = true;
          StandardOutPath = "/tmp/colima-${cfg.name}.out.log";
          StandardErrorPath = "/tmp/colima-${cfg.name}.err.log";
        };
      };
  };
}
