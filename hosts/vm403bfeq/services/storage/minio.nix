{ pkgs, config, ... }: {

  sops = {
    secrets = {
      "servers/cygnus-labs/minio/rootCredentialsFiles" = { };
      "servers/cygnus-labs/minio/secretKey" = { };
      "servers/cygnus-labs/minio/accessKey" = { };
    };
  };

  services.nginx = {
    virtualHosts = {
      "minio.platform.cygnus-labs.com" = {
        useACMEHost = "cygnus-labs.com";
        forceSSL = true;
        #enableACME = true;
        locations."/".proxyPass = "http://localhost:9000";
      };
      "minio-console.platform.cygnus-labs.com" = {
        useACMEHost = "cygnus-labs.com";
        forceSSL = true;
        #enableACME = true;
        locations."/".proxyPass = "http://localhost:9001";
      };
    };
  };

  # S3 compatible storage service
  services.minio = {
    enable = true;
    package = pkgs.unstable.minio;
    region = "af-south-1";
    #secretKey = config.sops.secrets."servers/cygnus-labs/minio/secretKey".path;
    #accessKey = config.sops.secrets."servers/cygnus-labs/minio/accessKey".path;
    rootCredentialsFile =
      config.sops.secrets."servers/cygnus-labs/minio/rootCredentialsFiles".path;
  };

}

