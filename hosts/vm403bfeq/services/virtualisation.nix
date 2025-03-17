{ pkgs, ... }: {

  # Useful tools
  environment.systemPackages = with pkgs;
    [
      lazydocker
      #  podman-tui # status of containers in the terminal
      #  podman-compose # start group of containers for dev
    ];

  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      flags = [ "--all" ];
      dates = "daily";
    };
    daemon.settings = {
      "storage-opts" = [ "dm.min_free_space=2%" ];
      "image-gc-high-threshold" = 90;
      "image-gc-low-threshold" = 80;
    };
  };

  virtualisation.containerd = {
    enable = true;
    settings = {
      "disabled_plugins" = [ ];
      "imports" = [ ];
      "oom_score" = 0;
      "version" = 2;
      "plugins.io.containerd.gc.v1.settings" = {
        "pause_threshold" = "0.02";
        "deletion_threshold" = "0.01";
        "max_deleted_at_age" = "24h";
        "mutation_threshold" = "10";
      };
    };
  };

  #virtualisation.containers.enable = true;
  #virtualisation = {
  #  podman = {
  #    enable = true;
  #    dockerCompat = true;
  #    dockerSocket.enable = true;
  #    defaultNetwork.settings.dns_enabled = true;
  #  };
  #  oci-containers.backend = "podman";
  #};

  # virtualisation.oci-containers.containers = {
  #   helloworld = {
  #     image = "testcontainers/helloworld:latest";
  #     ports = ["8080:8080" "8081:8081"];
  #   };
  # };

  # This is to prevent the DiskPresure to occure because the diskspace get full because of unused images 
  #systemd.services = {
  #  docker-images-prune = {
  #    description = "Prune Docker images";
  #    serviceConfig = {
  #      Type = "oneshot";
  #      ExecStart =
  #        ''${pkgs.docker}/bin/docker image prune --filter "label!=keep" -f'';
  #    };
  #  };
  #  containerd-prune = {
  #    description = "Prune Containerd images";
  #    serviceConfig = {
  #      Type = "oneshot";
  #      ExecStart = "${pkgs.containerd}/bin/ctr -n k8s.io images prune --all";
  #    };
  #  };
  #};
  #
  #systemd.timers = {
  #  docker-images-prune = {
  #    description = "Run Docker prune images weekly";
  #    timerConfig = {
  #      OnCalendar = "weekly";
  #      Persistent = true;
  #    };
  #    wantedBy = [ "timers.target" ];
  #  };
  #  containerd-prune = {
  #    description = "Run Containerd prune weekly";
  #    timerConfig = {
  #      OnCalendar = "weekly";
  #      Persistent = true;
  #    };
  #    wantedBy = [ "timers.target" ];
  #  };
  #};
}

