{ lib, pkgs, ... }: {
  virtualisation.oci-containers.containers."appflowy-cloud-postgres" = {
    image = "pgvector/pgvector:pg16";
    environment = {
      "POSTGRES_DB" = "postgres";
      "POSTGRES_HOST" = "postgres";
      "POSTGRES_PASSWORD" = "password";
      "POSTGRES_USER" = "admin";
      "SUPABASE_PASSWORD" = "root";
    };
    volumes = [
      "/home/nicoswan/Development/AppFlowy-Cloud/migrations/before:/docker-entrypoint-initdb.d:rw"
      "appflowy-cloud_postgres_data:/var/lib/postgresql/data:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      ''--health-cmd=["pg_isready", "-U", "admin"]''
      "--health-interval=5s"
      "--health-retries=6"
      "--health-timeout=5s"
      "--network-alias=postgres"
      "--network=appflowy-cloud_default"
    ];
  };
  systemd.services."podman-appflowy-cloud-postgres" = {
    serviceConfig = { Restart = lib.mkOverride 90 "on-failure"; };
    after = [
      "podman-network-appflowy-cloud_default.service"
      "podman-volume-appflowy-cloud_postgres_data.service"
    ];
    requires = [
      "podman-network-appflowy-cloud_default.service"
      "podman-volume-appflowy-cloud_postgres_data.service"
    ];
    partOf = [ "podman-compose-appflowy-cloud-root.target" ];
    wantedBy = [ "podman-compose-appflowy-cloud-root.target" ];
  };

  systemd.services."podman-volume-appflowy-cloud_postgres_data" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect appflowy-cloud_postgres_data || podman volume create appflowy-cloud_postgres_data
    '';
    partOf = [ "podman-compose-appflowy-cloud-root.target" ];
    wantedBy = [ "podman-compose-appflowy-cloud-root.target" ];
  };

}
