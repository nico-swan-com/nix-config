{
  # S3 compatible storage service
  services.minio = {
    enable = true;
    region = "af-south-1";
  };

  virtualHosts = {
      "minio.production.cygnus-labs.com" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://localhost:9000";
    };
  };
}

