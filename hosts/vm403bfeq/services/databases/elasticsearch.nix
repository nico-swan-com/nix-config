{
  services.elasticsearch = {
    enable = true;
    extraJavaOptions = [ "-Djava.net.preferIPv4Stack=true" ];
  };
}
