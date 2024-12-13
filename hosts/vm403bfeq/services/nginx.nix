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
        "*.cygnus-labs.com"
        "*.services.cygnus-labs.com"
        "*.development.cygnus-labs.com"
        "*.production.cygnus-labs.com"
        "*.platform.cygnus-labs.com"
        "*.security.cygnus-labs.com"
      ];
    };
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "~^(?<subdomain>.+)\\.(development|production|services)\\.cygnus-labs\\.com$" =
        {
          useACMEHost = "cygnus-labs.com";
          forceSSL = true;
          locations."/".proxyPass = "https://127.0.0.1:32060";
        };
    };
  };
}

