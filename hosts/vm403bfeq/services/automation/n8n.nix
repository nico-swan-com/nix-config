{
  services.n8n = { enable = true; };
  services.nginx = {
    virtualHosts = {
      "n8n.platform.cygnus-labs.com" = {
        useACMEHost = "cygnus-labs.com";
        forceSSL = true;
        locations = {
          "/" = {
            proxyWebsockets = true;
            proxyPass = "http://127.0.0.1:5678";
          };
        };
      };
    };
  };
}
