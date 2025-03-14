{ config, ... }: {

  sops = {
    secrets = {
      "servers/cygnus-labs/gitlab/runners/infrastructure/docker-images" = {
        owner = "git";
        group = "git";
      };
    };
  };

  services.gitlab-runner = {
    enable = true;
    services = {
      # runner for building in docker via host's nix-daemon
      # nix store will be readable in runner, might be insecure
      # runner for building docker images
      infrastructure-docker-images = {
        # File should contain at least these two variables:
        # `CI_SERVER_URL`
        # `CI_SERVER_TOKEN`
        authenticationTokenConfigFile = "${config.sops.secrets."servers/cygnus-labs/gitlab/runners/infrastructure/docker-images".path}";

        dockerImage = "docker:dind";
        dockerVolumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
        ];
      };
    };
  };
}
