{ pkgs, ... }: {

  imports = [
    # Infrastructure
    ./nginx.nix # Reverse proxy for edge
    ./virtualisation.nix # Postman / Docker container management for services
    ./kubernetes # Microservice container management for HA

    ./security/keycloak # IDP and authentication for edge
    #./security/kerberbos # Kerberos is a computer-network authentication protocol that works on the basis of tickets to allow nodes communicating over a non-secure network to prove their identity to one another in a secure manner.

    ./databases/postgres.nix # Application databases for platform and services
    ./databases/redis.nix # Caching database.
    #./databases/mongodb.nix # is a source-available, cross-platform, document-oriented database program. Classified as a NoSQL database.
    #./databases/elasticsearch.nix # is an open source distributed, RESTful search and analytics engine, scalable data store, and vector database.
    #./storage/minio.nix # Object storage solution like S3
    ./rclone.nix # Mount cloud storage and works with restic for backups
    ./restic.nix # Backup services

    # SDLC (Development)
    #./gitlab/gitlab.nix # Source code control and SDLC
    #./kubernetes # Miroservice container management for HA
    #./traefik.nix
    #./attic-server.nix

    # User platforms
    #./platform/solidtime
    #./platform/mattermost.nix
    #./platform/docmost.nix
    #./platform/appflowy.nix
    #./platform/ghost-blog

    ./game-servers/valheim.nix

    #./test-service.nix

  ];

  # Waiting for https://github.com/NixOS/nixpkgs/pull/390981 
  services.etcd = {
    enable = true;
    package = pkgs.stable.etcd;
  };
}
