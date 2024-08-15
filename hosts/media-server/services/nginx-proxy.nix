{

  security.acme = {
    acceptTerms = true;
    email = "REDACTED";
  };

  services.nginx.virtualHosts =
    let
      SSL = {
        enableACME = true;
        forceSSL = true;
      };
    in
    {
      "radarr.home.nicoswan.com" = (SSL // {
        locations."/".proxyPass = "http://127.0.0.1:7878";

        serverAliases = [
          "radarr.home.nicoswan.com"
        ];
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


