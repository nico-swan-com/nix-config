{ config, ... }: {
  sops = { secrets = { "servers/cygnus-labs/solidtime/envFile" = { }; }; };

  services.nginx = {
    virtualHosts = {
      "solidtime.platform.cygnus-labs.com" = {
        useACMEHost = "cygnus-labs.com";
        forceSSL = true;
        locations = {
          "/" = {
            #proxyWebsockets = true;
            proxyPass = "http://127.0.0.1:8001";
          };
        };
      };
    };
  };
  virtualisation.oci-containers.containers = {
    solidtime = {
      serviceName = "solidtime";
      image = "solidtime/solidtime";
      environmentFiles =
        [ config.sops.secrets."servers/cygnus-labs/solidtime/envFile".path ];
      environment = {
        APP_ENV = "production";
        APP_DEBUG = "false";
        APP_URL = "https://solidtime.platform.cygnus-labs.com";
        APP_FORCE_HTTPS = "false";
        APP_ENABLE_REGISTRATION = "false";
        TRUSTED_PROXIES = "0.0.0.0/0,2000:0:0:0:0:0:0:0/3";
        S3_ENDPOINT = "102.135.163.95:9000";
        QUEUE_CONNECTION = "database";
        AUTO_DB_MIGRATE = "false";
      };
      #extraOptions = [ "--cap-add=sys_nice" "--stop-timeout 120" ];

      ports = [ "8001:8000" ];
    };
  };

}
