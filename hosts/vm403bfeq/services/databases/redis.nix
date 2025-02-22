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
        requirePassFile =
          config.sops.secrets."servers/cygnus-labs/redis/requirePassFile".path;
        #user = "nextcloud";
        #unixSocket = "/run/redis-nextcloud/redis.sock";
        port = 6380;
        bind = null;
      };
    };
  };
}
