{
  services.nginx = {
    virtualHosts."git.cygnus-labs.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
    };
  };

  
}
