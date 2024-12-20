{ pkgs, lib, ... }:

{

  # Builds
  systemd.services."podman-build-appflowy-cloud-admin_frontend" = {
    path = [ pkgs.podman pkgs.git ];
    serviceConfig = {
      Type = "oneshot";
      TimeoutSec = 300;
    };
    script = ''
      cd /home/nicoswan/Development/AppFlowy-Cloud
      podman build -t appflowyinc/admin_frontend:latest -f ./admin_frontend/Dockerfile .
    '';
  };
  systemd.services."podman-build-appflowy-cloud-appflowy_cloud" = {
    path = [ pkgs.podman pkgs.git ];
    serviceConfig = {
      Type = "oneshot";
      TimeoutSec = 300;
    };
    script = ''
      cd /home/nicoswan/Development/AppFlowy-Cloud
      podman build -t appflowyinc/appflowy_cloud:latest --build-arg FEATURES= .
    '';
  };
  systemd.services."podman-build-appflowy-cloud-appflowy_worker" = {
    path = [ pkgs.podman pkgs.git ];
    serviceConfig = {
      Type = "oneshot";
      TimeoutSec = 300;
    };
    script = ''
      cd /home/nicoswan/Development/AppFlowy-Cloud
      podman build -t appflowyinc/appflowy_worker:latest -f ./services/appflowy-worker/Dockerfile .
    '';
  };
  systemd.services."podman-build-appflowy-cloud-gotrue" = {
    path = [ pkgs.podman pkgs.git ];
    serviceConfig = {
      Type = "oneshot";
      TimeoutSec = 300;
    };
    script = ''
      cd /home/nicoswan/Development/AppFlowy-Cloud/docker/gotrue
      podman build -t appflowyinc/gotrue:latest .
    '';
  };

}

