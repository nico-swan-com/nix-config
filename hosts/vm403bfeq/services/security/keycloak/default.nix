{ config, pkgs, ... }:
let
  username = "$(cat ${
      config.sops.secrets."servers/cygnus-labs/keycloak/dbUsername".path
    })";
  passwordFile =
    config.sops.secrets."servers/cygnus-labs/keycloak/dbPassword".path;
in {

  sops = {
    secrets = {
      "servers/cygnus-labs/keycloak/dbUsername" = { };
      "servers/cygnus-labs/keycloak/dbPassword" = { };
    };
  };

  environment.systemPackages = with pkgs.unstable; [ keycloak ];

  services.nginx = {
    upstreams = {
      keycloak = {
        extraConfig = ''
          ip_hash;
          keepalive 16;
        '';
        servers = { "127.0.0.1:38080" = { weight = 5; }; };
      };
    };

    virtualHosts = {
      "keycloak.cygnus-labs.com" = {
        useACMEHost = "cygnus-labs.com";
        #enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://127.0.0.1:38080";
      };
      "auth.cygnus-labs.com" = {
        useACMEHost = "cygnus-labs.com";
        #enableACME = true;
        forceSSL = true;
        locations = {
          "/" = {
            proxyPass =
              "http://127.0.0.1:38080/realms/production/protocol/openid-connect/userinfo";
            extraConfig = ''
              proxy_ssl_server_name on;
              proxy_pass_request_body off;
              proxy_set_header Content-Length "";
              proxy_set_header X-Original-URI $request_uri;
            '';
          };
        };
      };
    };
  };

  services.keycloak = {
    enable = true;
    package = pkgs.unstable.keycloak;
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

