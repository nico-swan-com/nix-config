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
    };
  };
}
