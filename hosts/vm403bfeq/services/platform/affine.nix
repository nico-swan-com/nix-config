{ config, ... }: {

  sops = { secrets = { "servers/cygnus-labs/affine/envFile" = { }; }; };

  virtualisation.oci-containers.containers = {
    affine_migration = {
      image = "ghcr.io/toeverything/affine:stable";
      environmentFiles =
        [ config.sops.secrets."servers/cygnus-labs/affine/envFile".path ];
      environment = {
        AFFINE_INDEXER_ENABLED = "true";
        AFFINE_REVISION = "stable";
        AFFINE_SERVER_HOST = "affine.platform.cygnus-labs.com";
        AFFINE_SERVER_EXTERNAL_URL = "https://affine.platform.cygnus-labs.com";
        PORT = "3010";
        MAILER_IGNORE_TLS = "false";
        NODE_OPTIONS = "--openssl-legacy-provider";
      };
      cmd = [ "sh" "-c" "node ./scripts/self-host-predeploy.js" ];
      volumes = [
        "/data/affine/storage:/root/.affine/storage"
        "/data/affine/config:/root/.affine/config"
      ];
    };

    affine = {
      image = "ghcr.io/toeverything/affine:stable";
      environmentFiles =
        [ config.sops.secrets."servers/cygnus-labs/affine/envFile".path ];
      environment = {
        AFFINE_INDEXER_ENABLED = "true";
        AFFINE_REVISION = "stable";
        AFFINE_SERVER_HOST = "affine.platform.cygnus-labs.com";
        AFFINE_SERVER_EXTERNAL_URL = "https://affine.platform.cygnus-labs.com";
        PORT = "3010";
        MAILER_IGNORE_TLS = "false";
        NODE_OPTIONS = "--openssl-legacy-provider";
      };
      volumes = [
        "/data/affine/storage:/root/.affine/storage"
        "/data/affine/config:/root/.affine/config"
      ];
      ports = [ "3010:3010" ];
    };
  };

  services.nginx = {
    virtualHosts = {
      "affine.platform.cygnus-labs.com" = {
        useACMEHost = "cygnus-labs.com";
        forceSSL = true;
        locations = {
          "/" = {
            #proxyWebsockets = true;
            proxyPass = "http://127.0.0.1:3010";
          };
        };
      };
    };
  };

  services.redis = {
    servers = {
      "affine" = {
        enable = true;
        openFirewall = false;
        port = 6390;
        bind = null;
      };
    };
  };

  system.activationScripts.affineData.text = ''
    mkdir -p /data/affine/storage
    mkdir -p /data/affine/config
  '';

  systemd.tmpfiles.rules = [
    "d /data/affine/storage 0755 root root"
    "d /data/affine/config 0755 root root"
  ];

  # Ensure main service starts after migration completes (podman units)
  systemd.services."podman-affine" = {
    after = [ "podman-affine_migration.service" ];
    requires = [ "podman-affine_migration.service" ];
  };
}


