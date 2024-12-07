{ config, ... }: {

  sops = {
    secrets = {
      "servers/cygnus-labs/gitlab/runners/docker-images" = {
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
      docker-images = {
        # File should contain at least these two variables:
        # `CI_SERVER_URL`
        # `CI_SERVER_TOKEN`
        authenticationTokenConfigFile = "${config.sops.secrets."servers/cygnus-labs/gitlab/runners/docker-images".path}";

        dockerImage = "docker:stable";
        dockerVolumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
        ];
      };
    };
  };
}
