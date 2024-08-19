{

  imports = [
    # ./nginx.nix
    ./virtualisation.nix
    ./minio.nix
    #./gitlab.nix
    ./kubernetes.nix
    ./databases/postgres.nix
    ./databases/redis.nix
  ];

}
