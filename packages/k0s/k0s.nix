{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.k0s;
  configFile = pkgs.writeText "Corefile" cfg.config;
in
{
  options.services.k0s = {
    enable = mkEnableOption "Docker k0s server";

    version = mkOption {
      default = "v1.30.4-k0s.0";
      example = "v1.30.4-k0s.0";
      type = types.str;
      description = "Version of k0s to use.";
    };

    volume = mkOption {
      default = "/var/lib/k0s";
      example = "/var/lib/k0s";
      type = types.str;
      description = "Directory to store k0s data.";
    };

    dataStorageLocation = mkOption {
      default = "~/.config/k0s/volumes";
      example = "openEBS";
      type = types.str;
      description = "Volume mount for openEBS storage to use.";
    };

    port = mkOption {
      default = "6443";
      example = "6443";
      type = types.str;
      description = "Port to use.";
    };

    podman = mkOption {
      default = false;
      type = types.bool;
      description = "Use podman instead of docker.";
    };

    configDir = mkOption {
      default = "~/.config/k0s/etc";
      example = "~/.config/k0s/etc";
      type = types.str;
      description = "Directory to store k0s config.";
    };

    config = mkOption {
      default = ''
        apiVersion: k0s.k0sproject.io/v1beta1
        kind: ClusterConfig
          metadata:
          name: k0s
            spec:
            extensions:
            helm: { }
              storage:
              type: openebs_local_storage

      '';
      example = ''
        apiVersion: k0s.k0sproject.io/v1beta1
        kind: ClusterConfig
          metadata:
          name: k0s
            spec:
            extensions:
            helm: { }
              storage:
              type: openebs_local_storage
      '';
      type = types.lines;
      description = ''
        config.yaml file
      '';
    };

    package = mkPackageOption pkgs "k0s" { };

  };

  config = mkIf cfg.enable rec {
    launchd.daemons.k0s =
      let
        runtime = if cfg.podman then "${pkgs.podman}/bin/podman" else "${pkgs.docker}/bin/docker";
        parameters = '' run --name k0s --hostname k0s --privileged \
                   --cgroupns=host -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
                   --restart unless-stopped \
                   -v /var/lib/k0s \
                   -v ${cfg.configDir}:/etc/k0s:rw \
                   -v ${cfg.configDir}/config.yaml:/etc/k0s/config.yaml:rw \
                   -v ${cfg.dataStorageLocation}:/var/openebs/local:z \
                   -p 6443:${cfg.port}  \
                   docker.io/k0sproject/k0s:${cfg.version} k0s controller --enable-worker --no-taints --enable-dynamic-config
        '';

        startScript = ''
          export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/run/current-system/sw/bin"

          function shutdown() {
            ${runtime} container stop k0s
            exit 0
          }

          trap shutdown SIGTERM
          trap shutdown SIGINT

          # wait until k0s is running
          while true; do
            ${runtime} container ls - a | grep ${cfg.version} &>/dev/null
            if [ $? -eq 0 ]; then
              break
            fi
            RUNNING=`${runtime} container ls -a | grep ${cfg.version}`
            if [ -z "$RUNNING" ]; then
              echo "Creating k0s container"
              ${runtime} ${parameters}
            else
              echo "Starting k0s container"
              ${runtime} container start k0s
              ${runtime} container logs -f k0s
            fi

            sleep 5
          done

          tail -f /dev/null &
          wait $!
        '';
      in
      {
        script = startScript;
        serviceConfig = {
          KeepAlive = true;
          RunAtLoad = true;
          StandardOutPath = "/tmp/k0s.out.log";
          StandardErrorPath = "/tmp/k0s.err.log";
        };
      };



    #   launchd.daemons.k0s-monitor =
    #     let
    #       runtime = if cfg.podman then "${pkgs.podman}/bin/podman" else "${pkgs.docker}/bin/docker";
    #       monitorScript = ''
    #         #
    #         while true; do
    #           if ! launchctl list | grep -q "local.k0s"; then
    #             ${runtime} container stop k0s > /dev/null 
    #             break
    #           fi
    #           sleep 5
    #         done
    #       '';
    #     in
    #     {
    #       script = monitorScript;
    #       serviceConfig = {
    #         Disabled = true;
    #         KeepAlive = true;
    #         RunAtLoad = true;
    #         StandardOutPath = "/tmp/k0s-monitor.out.log";
    #         StandardErrorPath = "/tmp/k0s-monitor.err.log";
    #       };
    #     };
  };
}
