{ config, ... }: {

  sops = { secrets = { "servers/cygnus-labs/redis/requirePassFile" = { }; }; };

  services.redis = {
    servers = {
      "cygnus-labs" = {
        enable = true;
        openFirewall = true;
        requirePassFile =
          config.sops.secrets."servers/cygnus-labs/redis/requirePassFile".path;
        port = 6379;
        bind = null;
      };
      "penpot" = {
        enable = true;
        openFirewall = true;
        port = 6380;
        bind = null;
        settings = { protected-mode = "no"; };
      };

      "docmost" = {
        enable = true;
        openFirewall = true;
        port = 6381;
        bind = null;
        settings = { protected-mode = "no"; };
      };

    };
  };
}
