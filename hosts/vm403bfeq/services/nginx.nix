{ config, pkgs, ... }:

let
  cloudflareEnvFile =
    "${config.sops.secrets."servers/cygnus-labs/external-services/cloudflare/envFile".path}";
  cloudflareEmail = "dev@cygnus-labs.com";
in {

  sops = {
    secrets = {
      "servers/cygnus-labs/external-services/cloudflare/email" = { };
      "servers/cygnus-labs/external-services/cloudflare/envFile" = { };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "${cloudflareEmail}";
    certs."cygnus-labs.com" = {
      domain = "cygnus-labs.com";
      dnsProvider = "cloudflare";
      dnsPropagationCheck = true;
      credentialsFile = "${cloudflareEnvFile}";
      group = "nginx";
      extraDomainNames = [
        "*.cygnus-healthlabs.com"
        "*.services.cygnus-labs.com"
        "*.development.cygnus-labs.com"
        "*.production.cygnus-labs.com"
        "*.platform.cygnus-labs.com"
        "*.security.cygnus-labs.com"
        "*.s3.cygnus-labs.com"
      ];
    };
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    clientMaxBodySize = "500m";

    virtualHosts = {
      "health.cygnus-labs.com" = {
        useACMEHost = "cygnus-labs.com";
        forceSSL = true;
        locations = {
          "/" = {
            extraConfig = ''
              add_header Content-Type application/json;
              return 200 '{"status":"healthy","timestamp":"$time_iso8601","service":"api.cygnus-labs.com"}';
            '';
          };
        };
      };

      "vm403bfeq.cygnus-labs.com" = {
        locations = {
          "/health" = {
            extraConfig = ''
              add_header Content-Type application/json;
              return 200 '{"status":"healthy","timestamp":"$time_iso8601", "hostname":"vm403bfeq.cygnus-labs.com"}';
            '';
          };
        };
      };

      "~^(?<subdomain>.+)\\.(development|production|services)\\.cygnus-labs\\.com$" =
        {
          useACMEHost = "cygnus-labs.com";
          forceSSL = true;
          locations = {
            "/" = {
              proxyPass = "https://127.0.0.1:32060";
              proxyWebsockets = true;
              #extraConfig = ''
              #  error_page 502 @fallback;
              #'';
            };
            #"@fallback".proxyPass = "https://www.cygnus-labs.com";
          };
        };
    };
  };
}

