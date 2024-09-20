{ config, pkgs, ... }:

let
  cloudflareEmail = "${config.sops.secrets."servers/cygnus-labs/services/cloudflare/email".path}";
  cloudflareApiKey = "${config.sops.secrets."servers/cygnus-labs/services/cloudflare/apiKey".path}";
  traefikConfig = {
    # Static configuration for Traefik
    staticConfigOptions = {
      entryPoints = {
        web = {
          address = ":80";
        };
        websecure = {
          address = ":443";
        };
      };
      certificatesResolvers = {
        cloudflare = {
          acme = {
            email = "nico.swan@cygnus-labs.com";
            storage = "/etc/traefik/acme.json";
            dnsChallenge = {
              provider = "cloudflare";
              delayBeforeCheck = 0;
            };
          };
        };
      };
    };
    # Dynamic configuration for Traefik
    dynamicConfigOptions = {
      http = {
        routers = {
          to-k8s = {
            entryPoints = ["websecure"];
            rule = "HostRegexp(`{subdomain:.*}.services.production.cygnus-labs.com`)";
            service = "k8s-service";
            tls = {
              certResolver = "cloudflare";
            };
          };
        };
        services = {
          "k8s-service" = {
            loadBalancer = {
              servers = [
                { url = "http://k8s-loadbalancer-ip:port"; }
              ];
            };
          };
        };
      };
    };
  };
in
{

  sops = {
    secrets = {
      "servers/cygnus-labs/services/cloudflare/email" = {};
      "servers/cygnus-labs/services/cloudflare/apiKey" = {};
    };
  };

  # services.traefik = {
  #   enable = true;
  #   package = pkgs.traefik;
  #   settings = traefikConfig;
  # };

  environment.variables = {
    CF_API_EMAIL = "${config.environment.etc."traefik/secrets.yaml".value.CF_API_EMAIL}";
    CF_API_KEY = "${config.environment.etc."traefik/secrets.yaml".value.CF_API_KEY}";
  };
}
