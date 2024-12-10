{ pkgs, config, ... }: {
  sops = { secrets = { "servers/cygnus-labs/mattermost/dbPassword" = { }; }; };

  environment.systemPackages = with pkgs.unstable; [ mattermost ];

  services.nginx = {
    virtualHosts = {
      "chat.platform.cygnus-labs.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://127.0.0.1:8065";
      };
    };
  };

  services.mattermost = {
    enable = true;
    package = pkgs.unstable.mattermost;
    siteName = "Cygnus-labs";
    siteUrl = "https://chat.platform.cygnus-labs.com";
    mutableConfig = true;
  };
}
