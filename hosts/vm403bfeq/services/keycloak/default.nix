{ config, pkgs, ... }:
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

  environment.systemPackages = with pkgs; [
    keycloak
  ];

  services.nginx = {
    virtualHosts = {
      "keycloak.cygnus-labs.com" = {
        useACMEHost = "cygnus-labs.com";
        #enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://localhost:38080";
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

    initialAdminPassword = "changeme";
    settings = {
      http-enabled = true;
      hostname-strict-https = true;
      https-port = 38081;
      http-relative-path = "/";
      http-port = 38080;
      hostname = "https://keycloak.cygnus-labs.com";
      http-host = "127.0.0.1";
    # Uncomment the following line if you need to add CSP headers directly to Keycloak
      securityHeaders = "frame-src 'self' http://keycloak.cygnus-labs.com";

    };

  };
}

