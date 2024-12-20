{ lib, pkgs, ... }: {
  virtualisation.oci-containers.containers."appflowy-cloud-minio" = {
    image = "minio/minio";
    environment = {
      "MINIO_BROWSER_REDIRECT_URL" = "http://localhost:9999/minio";
      "MINIO_ROOT_PASSWORD" = "minioadmin";
      "MINIO_ROOT_USER" = "minioadmin";
    };
    volumes = [ "appflowy-cloud_minio_data:/data:rw" ];
    cmd = [ "server" "/data" "--console-address" ":9001" ];
    log-driver = "journald";
    extraOptions =
      [ "--network-alias=minio" "--network=appflowy-cloud_default" ];
  };
  systemd.services."podman-appflowy-cloud-minio" = {
    serviceConfig = { Restart = lib.mkOverride 90 "on-failure"; };
    after = [
      "podman-network-appflowy-cloud_default.service"
      "podman-volume-appflowy-cloud_minio_data.service"
    ];
    requires = [
      "podman-network-appflowy-cloud_default.service"
      "podman-volume-appflowy-cloud_minio_data.service"
    ];
    partOf = [ "podman-compose-appflowy-cloud-root.target" ];
    wantedBy = [ "podman-compose-appflowy-cloud-root.target" ];
  };

  # Volumes
  systemd.services."podman-volume-appflowy-cloud_minio_data" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect appflowy-cloud_minio_data || podman volume create appflowy-cloud_minio_data
    '';
    partOf = [ "podman-compose-appflowy-cloud-root.target" ];
    wantedBy = [ "podman-compose-appflowy-cloud-root.target" ];
  };

}
