{ config, pkgs, ... }:
{
  imports = [
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
    kubernetes-helm
    helmfile
  ];

}
