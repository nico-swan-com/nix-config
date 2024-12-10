{

  imports = [
    # Infrastrucure
    ./nginx.nix # Reverse proxy for edge
    ./keycloak # IDP and authentication for edge
    ./databases/postgres.nix # Application databases for platfrom and services
    ./databases/redis.nix # cacheing databases
    ./rclone.nix # mount cload storage and works with restic for backups
    ./restic.nix # Backupd services

    #./minio.nix             # Object storage solution like S3
    ./gitlab/gitlab.nix # Source code control and SDLC
    ./kubernetes # Miroservice container management for HA
    #./traefik.nix
    ./virtualisation.nix # Postman / Docker container management for services

    # User platforms
    ./platform/mattermost.nix
  ];

}
