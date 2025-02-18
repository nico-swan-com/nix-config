{ pkgs, ... }: {
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      flags = [ ];
      dates = "monthly";
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

  # Useful tools
  environment.systemPackages = with pkgs; [
    podman-tui # status of containers in the terminal
    podman-compose # start group of containers for dev
  ];

  # virtualisation.oci-containers.containers = {
  #   helloworld = {
  #     image = "testcontainers/helloworld:latest";
  #     ports = ["8080:8080" "8081:8081"];
  #   };
  # };

  # This is to prevent the DiskPresure to occure because the diskspace get full because of unused images 
  systemd.services = {
    docker-images-prune = {
      description = "Prune Docker images";
      serviceConfig = {
        Type = "oneshot";
        ExecStart =
          ''${pkgs.docker}/bin/docker image prune --filter "label!=keep" -f'';
      };
    };
    containerd-prune = {
      description = "Prune Containerd images";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = ''
          ${pkgs.containerd}/bin/ctr -n k8s.io images prune --all --filter "labels.tag!=keep"'';
      };
    };
  };

  systemd.timers = {
    docker-images-prune = {
      description = "Run Docker prune images weekly";
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
    containerd-prune = {
      description = "Run Containerd prune weekly";
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
  };
}

