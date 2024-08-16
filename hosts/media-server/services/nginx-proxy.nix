{

  security.acme = {
    defaults.email = "REDACTED";
    acceptTerms = true;
  };

  services.nginx.enable = true;
 
  services.nginx.virtualHosts =
    let
      SSL = {
        enableACME = true;
        forceSSL = true;
      };
    in
    {
      "plex.home.nicoswan.com" = (SSL // {
        locations."/".proxyPass = "http://127.0.0.1:32400";
      });

      "radarr.home.nicoswan.com" = (SSL // {
        locations."/".proxyPass = "http://127.0.0.1:7878";
      });

      "sonarr.home.nicoswan.com" = (SSL // {
        locations."/".proxyPass = "http://127.0.0.1:8989";
      });

      "ombi.home.nicoswan.com" = (SSL // {
        locations."/".proxyPass = "http://127.0.0.1:5000";
      });

      "qbittorrent.home.nicoswan.com" = (SSL // {
        locations."/".proxyPass = "http://127.0.0.1:9010";
      });
      
      "jackett.home.nicoswan.com" = (SSL // {
        locations."/".proxyPass = "http://127.0.0.1:9117";
      });

    };
}


