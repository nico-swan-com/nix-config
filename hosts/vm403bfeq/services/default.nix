{

  imports = [
    # Infrastrucure
    ./nginx.nix # Reverse proxy for edge
    ./security/keycloak # IDP and authentication for edge
    #./security/kerberbos # Kerberos is a computer-network authentication protocol that works on the basis of tickets to allow nodes communicating over a non-secure network to prove their identity to one another in a secure manner.
    ./databases/postgres.nix # Application databases for platfrom and services
    ./databases/redis.nix # cacheing databases
    ./storage/minio.nix # Object storage solution like S3
    ./rclone.nix # mount cload storage and works with restic for backups
    ./restic.nix # Backupd services

    # SDLC (Development)
    ./gitlab/gitlab.nix # Source code control and SDLC
    ./kubernetes # Miroservice container management for HA
    #./traefik.nix
    ./virtualisation.nix # Postman / Docker container management for services

    # User platforms
    ./platform/mattermost.nix
    #./platform/appflowy.nix
    ./platform/ghost-blog
  ];

}
