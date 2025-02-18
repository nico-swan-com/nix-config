{ config, pkgs, ... }:
let
  my-kubernetes-helm = with pkgs;
    wrapHelm kubernetes-helm {
      plugins = with pkgs.kubernetes-helmPlugins; [
        helm-secrets
        helm-diff
        helm-s3
        helm-git
      ];
    };

  my-helmfile =
    pkgs.helmfile-wrapped.override { inherit (my-kubernetes-helm) pluginsDir; };
in {
  imports = [
    #./certificates.nix
    ./cluster.nix
    #./kubenix-modules/cluster
  ];
  # packages for administration tasks
  environment.systemPackages = with pkgs; [
    kompose
    kubectl
    kubernetes
    k9s
    argocd
    kail
    my-kubernetes-helm
    my-helmfile
  ];

  # This is to prevent the DiskPresure to occure because the diskspace get full because of unused images 
  systemd.services = {
    docker-prune = {
      description = "Prune Docker images";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.docker}/bin/docker image prune -a -f";
      };
    };
    containerd-prune = {
      description = "Prune Containerd images";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.containerd}/bin/ctr -n k8s.io images prune --all";
      };
    };
  };

  systemd.timers = {
    docker-prune = {
      description = "Run Docker prune weekly";
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
    containerd-prune = {
      description = "Run Containerd prune weekly";
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
  };

}
