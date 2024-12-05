{ config, ... }:
let
  username = "$(cat ${config.sops.secrets."servers/cygnus-labs/keycloak/dbUsername".path})";
  passwordFile = config.sops.secrets."servers/cygnus-labs/keycloak/dbPassword".path;
in
{

  sops = {
     secrets = {
        "servers/cygnus-labs/keycloak/dbUsername" = {}; 
        "servers/cygnus-labs/keycloak/dbPassword" = {}; 
     };
  };

  services.nginx = {
    virtualHosts = {
      "keycloak.cygnus-labs.com" = {
        #useACMEHost = "cygnus-labs.com";
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://127.0.0.1:38080";
      };
    };
  };

  services.keycloak = {
    enable = true;

    database = {
      type = "postgresql";
      createLocally = true;

      username = "keycloak";
      passwordFile = "${passwordFile}";
    };

    settings = {
      hostname = "keycloak.cygnus-labs.com";
      http-enabled = true;
      hostname-strict-https = true;
      https-port = 38081;
      http-relative-path = "/";
      http-port = 38080;
      #proxy = "passthrough";
    };
  };
}
