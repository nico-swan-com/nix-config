{ config, ... }: {

  sops = { secrets = { "servers/cygnus-labs/docmost/envFile" = { }; }; };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    clientMaxBodySize = "500m";

    virtualHosts = {
      "docs.cygnus-labs.com" = {
        useACMEHost = "cygnus-labs.com";
        forceSSL = true;
        locations = {
          "/" = {
            #proxyWebsockets = true;
            proxyPass = "http://127.0.0.1:3000";
          };
        };
      };
    };
  };

  virtualisation.oci-containers.containers = {
    docmost = {
      image = "docmost/docmost:latest";
      environmentFiles =
        [ config.sops.secrets."servers/cygnus-labs/docmost/envFile".path ];
      environment = {
        APP_URL = "http://docs.cygnus-labs.com";
        REDIS_URL = "redis://102.135.163.95:6381";
        STORAGE_DRIVER = "s3";
        AWS_S3_REGION = "af-south-1";
        AWS_S3_BUCKET = "docmost";
        AWS_S3_ENDPOINT = "102.135.163.95:9000";
        AWS_S3_FORCE_PATH_STYLE = "true";
        MAIL_DRIVER = "smtp";
        SMTP_HOST = "mail.cygnus-labs.com";
        SMTP_PORT = "465";
        SMTP_SECURE = "true";
        MAIL_FROM_ADDRESS = "notifications@cygnus-labs.com";
        MAIL_FROM_NAME = "Notifications";
      };
      ports = [ "3000:3000" ];
    };
  };

}
