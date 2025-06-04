{ config, ... }: {

  sops = {
    secrets = {
      "servers/cygnus-labs/gitlab/runners/gitlabcom/default" = {
        owner = "git";
        group = "git";
      };
    };
  };

  services.gitlab-runner = {
    enable = true;
    services = {
      gitlabcom = {
        # File should contain at least these two variables:
        # `CI_SERVER_URL`
        # `CI_SERVER_TOKEN`
        authenticationTokenConfigFile =
          "${config.sops.secrets."servers/cygnus-labs/gitlab/runners/gitlabcom/default".path}";

        dockerImage = "alpine:latest";

      };
    };
  };
}
