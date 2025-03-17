{
  services.renovate = {
    enable = true;
    settings = {
      endpoint = "https://git.cygnus-labs.com";
      gitAuthor = "Renovate <renovate@example.com>";
      platform = "gitlab";
    };
    schedule = "*:0/10";
    credentials = { RENOVATE_TOKEN = "/etc/renovate/token"; };
  };
}
