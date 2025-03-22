{

  services.redis = {
    servers = {
      "penpot" = {
        enable = true;
        openFirewall = true;
        port = 6380;
        bind = null;
        settings = { protected-mode = "no"; };
      };
    };
  };
}
