{
  virtualisation.docker.enable = false;
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    oci-containers.backend = "podman";
  };

  virtualisation.oci-containers.containers = {
    helloworld = {
      image = "testcontainers/helloworld:latest";
      ports = ["8080:8080" "8081:8081"];
    };
  };
}

