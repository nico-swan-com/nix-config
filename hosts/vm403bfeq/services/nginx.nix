{

  security.acme = {
    defaults.email = "nico.swan@cygnus-labs.com";
    acceptTerms = true;
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };
}