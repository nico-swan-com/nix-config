{ lib, ... }: {
  virtualisation.oci-containers.containers."appflowy-cloud-redis" = {
    image = "redis";
    log-driver = "journald";
    extraOptions =
      [ "--network-alias=redis" "--network=appflowy-cloud_default" ];
  };
  systemd.services."podman-appflowy-cloud-redis" = {
    serviceConfig = { Restart = lib.mkOverride 90 "on-failure"; };
    after = [ "podman-network-appflowy-cloud_default.service" ];
    requires = [ "podman-network-appflowy-cloud_default.service" ];
    partOf = [ "podman-compose-appflowy-cloud-root.target" ];
    wantedBy = [ "podman-compose-appflowy-cloud-root.target" ];
  };

}
