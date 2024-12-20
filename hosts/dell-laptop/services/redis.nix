{
  services.redis = {
    servers = {
      "cygnus-labs" = {
        enable = true;
        port = 6379;
      };
      "appflowy" = {
        enable = true;
        port = 6378;
      };
    };
  };
}
