{

  imports = [
    #./traefik.nix
    ./nginx.nix
    ./virtualisation.nix
    #./minio.nix
    ./gitlab/gitlab.nix
    ./kubernetes
    ./databases/postgres.nix
    ./databases/redis.nix
    ./keycloak
    ./rclone.nix
    ./restic.nix
  ];

}
