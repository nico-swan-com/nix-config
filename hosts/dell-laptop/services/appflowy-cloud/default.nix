{ pkgs, lib, ... }: {

  imports = [
    #./appflowy-cloud.frontend.nix
    #./appflowy-cloud.ai.nix
    #./appflowy-cloud.appflowy-cloud.nix
    ./appflowy-cloud.worker.nix
    #./minio.nix
    #./gotrue.nix
    #./postgres.nix
    #./redis.nix
  ];

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-appflowy-cloud-root" = {
    unitConfig = { Description = "Root target generated by compose2nix."; };
    wantedBy = [ "multi-user.target" ];
  };

  #virtualisation.oci-containers.containers."appflowy-cloud-nginx" = {
  #  image = "nginx";
  #  volumes = [
  #    "/home/nicoswan/Development/AppFlowy-Cloud/nginx/nginx.conf:/etc/nginx/nginx.conf:rw"
  #    "/home/nicoswan/Development/AppFlowy-Cloud/nginx/ssl/certificate.crt:/etc/nginx/ssl/certificate.crt:rw"
  #    "/home/nicoswan/Development/AppFlowy-Cloud/nginx/ssl/private_key.key:/etc/nginx/ssl/private_key.key:rw"
  #  ];
  #  ports = [ "80:80/tcp" "443:443/tcp" ];
  #  log-driver = "journald";
  #  extraOptions =
  #    [ "--network-alias=nginx" "--network=appflowy-cloud_default" ];
  #};
  #systemd.services."podman-appflowy-cloud-nginx" = {
  #  serviceConfig = { Restart = lib.mkOverride 90 "on-failure"; };
  #  after = [ "podman-network-appflowy-cloud_default.service" ];
  #  requires = [ "podman-network-appflowy-cloud_default.service" ];
  #  partOf = [ "podman-compose-appflowy-cloud-root.target" ];
  #  wantedBy = [ "podman-compose-appflowy-cloud-root.target" ];
  #};

  # Networks
  systemd.services."podman-network-appflowy-cloud_default" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f appflowy-cloud_default";
    };
    script = ''
      podman network inspect appflowy-cloud_default || podman network create appflowy-cloud_default
    '';
    partOf = [ "podman-compose-appflowy-cloud-root.target" ];
    wantedBy = [ "podman-compose-appflowy-cloud-root.target" ];
  };

}

