{ pkgs, configVars, ... }:

{
  imports = [
    ../../modules/home-manager/colima.nix
    ../../modules/home-manager/nginx.nix

  ];

  home.packages = with pkgs; [
    k9s
  ];

  programs.zsh = {
    shellAliases = {
      "kcolima-dev-context" = "kubectl config use-context colima-development-cluster";
      "kdev" = "kubectl --context colima-development-cluster";
    };
  };

  services.colima = {
    enable = true;
    vms = [
      {
        cpu = 4;
        disk = 10;
        memory = 8;
        arch = "aarch64";
        runtime = "docker";
        hostname = "development-cluster";
        kubernetes ={
          enabled = true;
          k3sArgs = ["--no-deploy=traefik"]; 
          kubernetesDisable=["teafik"];
        };
        rosetta = false;
        network.address = true;
        launchd.enable = true;
      }
    ];
  };
}
