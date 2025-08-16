{ config, ... }: {

  users.users.git = {
    isSystemUser = true;
    group = "git";
  };
  users.groups.git = { };

  sops = {
    secrets = {
      "servers/cygnus-labs/gitlab/runners/gitlabcom/default" = {
        owner = "git";
        group = "git";
      };
      "servers/cygnus-labs/gitlab/runners/gitlabcom/k8s" = {
        owner = "git";
        group = "git";
      };
      "servers/cygnus-labs/gitlab/runners/gitlabcom/node" = {
        owner = "git";
        group = "git";
      };
      "servers/cygnus-labs/gitlab/runners/gitlabcom/node2" = {
        owner = "git";
        group = "git";
      };
      "servers/cygnus-labs/gitlab/runners/gitlabcom/docker" = {
        owner = "git";
        group = "git";
      };
    };
  };

  services.gitlab-runner = {
    enable = true;
    settings = { concurrent = 100; };
    services = {
      gitlabcom-default = {
        authenticationTokenConfigFile =
          "${config.sops.secrets."servers/cygnus-labs/gitlab/runners/gitlabcom/default".path}";
        dockerImage = "alpine:latest";
      };
      gitlabcom-k8s = {
        authenticationTokenConfigFile =
          "${config.sops.secrets."servers/cygnus-labs/gitlab/runners/gitlabcom/k8s".path}";
        dockerImage = "alpine/k8s:1.29.2";
      };
      gitlabcom-node = {
        authenticationTokenConfigFile =
          "${config.sops.secrets."servers/cygnus-labs/gitlab/runners/gitlabcom/node".path}";
        dockerImage = "node:22-slim";
      };
      gitlabcom-node2 = {
        authenticationTokenConfigFile =
          "${config.sops.secrets."servers/cygnus-labs/gitlab/runners/gitlabcom/node2".path}";
        dockerImage = "node:22-slim";
      };
      gitlabcom-docker = {
        authenticationTokenConfigFile =
          "${config.sops.secrets."servers/cygnus-labs/gitlab/runners/gitlabcom/docker".path}";
        dockerImage = "docker:dind";
        dockerVolumes = [ "/var/run/docker.sock:/var/run/docker.sock" ];
      };
    };
  };
}
