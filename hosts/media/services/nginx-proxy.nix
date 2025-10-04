{ config, pkgs, ... }:

let
  cloudflareEnvFile =
    "${config.sops.secrets."servers/home/cloudflare/envFile".path}";
  cloudflareEmail = "hi@nicoswan.com";
in {

  sops.secrets."servers/home/cloudflare/envFile".neededForUsers = true;

  security.acme = {
    acceptTerms = true;
    defaults.email = cloudflareEmail;
    certs = {
      "home.nicoswan.com" = {
        domain = "home.nicoswan.com";
        dnsProvider = "cloudflare";
        credentialsFile = cloudflareEnvFile;
        dnsPropagationCheck = true;
        group = "nginx";
        extraDomainNames = [ "*.home.nicoswan.com" ];
      };
      "pi-cluster.nicoswan.com" = {
        domain = "pi-cluster.nicoswan.com";
        dnsProvider = "cloudflare";
        credentialsFile = cloudflareEnvFile;
        group = "nginx";
        extraDomainNames = [ "*.pi-cluster.nicoswan.com" ];
      };
    };
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    clientMaxBodySize = "500m";
    serverNamesHashBucketSize = 128;
    proxyTimeout = "300s";

    #upstreams."pi_docker_swarm" = {
    #  servers = {
    #  "http://192.168.1.90" = {
    #    max_fails = 3;
    #    fail_timeout = "20s";
    #  };
    #
    #  "http://192.168.1.91" = { backup = true; };
    #};
    #};

    virtualHosts = let
      COMMON = {
        enableACME = true;
        forceSSL = true;
        locations."/robots.txt" = {
          extraConfig = ''
            rewrite ^/(.*)  $1;
            return 200 "User-agent: *\nDisallow: /";
          '';
        };

        extraConfig = ''
          add_header X-Robots-Tag "noindex, nofollow" always;
        '';
      };
    in {

      "~^(?<subdomain>.+)\\.pi-cluster\\.nicoswan\\.com$" = {
        useACMEHost = "pi-cluster.nicoswan.com";
        forceSSL = true;
        locations."/robots.txt" = {
          extraConfig = ''
            rewrite ^/(.*)  $1;
            return 200 "User-agent: *\nDisallow: /";
          '';
        };

        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://192.168.1.90";
          extraConfig = ''
            add_header X-Robots-Tag "noindex, nofollow" always;
          '';
        };
      };

      "plex.home.nicoswan.com" = (COMMON // {
        http2 = true;
        locations."/".proxyPass = "http://127.0.0.1:32400/";
      });

      "radarr.home.nicoswan.com" =
        (COMMON // { locations."/".proxyPass = "http://127.0.0.1:7878/"; });

      "sonarr.home.nicoswan.com" =
        (COMMON // { locations."/".proxyPass = "http://127.0.0.1:8989/"; });

      "ombi.home.nicoswan.com" =
        (COMMON // { locations."/".proxyPass = "http://127.0.0.1:5000/"; });

      "qbittorrent.home.nicoswan.com" =
        (COMMON // { locations."/".proxyPass = "http://127.0.0.1:9010/"; });

      "jackett.home.nicoswan.com" =
        (COMMON // { locations."/".proxyPass = "http://127.0.0.1:9117/"; });

      "tautulli.home.nicoswan.com" =
        (COMMON // { locations."/".proxyPass = "http://127.0.0.1:8181/"; });
    };
  };
}
