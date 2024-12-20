{ lib, ... }:
let
  adminFrontendUrl = "http://appflowy_cloud:8000";
  adminFrontendGoTrueUrl = "http://gotrue:9999";
  adminFrontendRedisUrl = "redis://redis:6379";
in {

  # Containers
  virtualisation.oci-containers.containers."appflowy-cloud-admin_frontend" = {
    image = "localhost/appflowyinc/admin_frontend:latest";
    environment = {
      "ADMIN_FRONTEND_APPFLOWY_CLOUD_URL" = "${adminFrontendUrl}";
      "ADMIN_FRONTEND_GOTRUE_URL" = "${adminFrontendGoTrueUrl}";
      "ADMIN_FRONTEND_REDIS_URL" = "${adminFrontendRedisUrl}";
      "RUST_LOG" = "info";
    };
    log-driver = "journald";
    extraOptions =
      [ "--network-alias=admin_frontend" "--network=appflowy-cloud_default" ];
  };
  systemd.services."podman-appflowy-cloud-admin_frontend" = {
    serviceConfig = { Restart = lib.mkOverride 90 "on-failure"; };
    after = [ "podman-network-appflowy-cloud_default.service" ];
    requires = [ "podman-network-appflowy-cloud_default.service" ];
    partOf = [ "podman-compose-appflowy-cloud-root.target" ];
    wantedBy = [ "podman-compose-appflowy-cloud-root.target" ];
  };

}
