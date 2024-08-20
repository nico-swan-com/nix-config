{ config, pkgs, ... }:
let
  # When using easyCerts=true the IP Address must resolve to the master on creation.
  # So use simply 127.0.0.1 in that case. Otherwise you will have errors like this https://github.com/NixOS/nixpkgs/issues/59364
  kubeMasterIP = "102.135.163.95";
  kubeMasterHostname = "api.kubernetes";
  kubeMasterAPIServerPort = 6443;

in
{
  # resolve master hostname
  networking.extraHosts = "${kubeMasterIP} ${kubeMasterHostname}";

  # packages for administration tasks
  environment.systemPackages = with pkgs; [
    kompose
    kubectl
    kubernetes
    k9s
    argocd
    podman-tui
    docker-compose
    kubernetes-helm
    openiscsi
    nfs-utils
    cryptsetup
    lvm2
  ];

  system.activationScripts.usrlocalbin = ''
    mkdir -m 0755 -p /usr/local
    ln -nsf /run/current-system/sw/bin /usr/local/
  '';
  services.openiscsi = {
    enable = true;
    #name = "iqn.2024-08.com.open-iscsi:${config.networking.hostName}";
    name = "iqn.2024-08.com.cygnus-labs.iscsi:${config.networking.hostName}";
  };

  services.kubernetes = {
    roles = [ "master" "node" ];
    masterAddress = kubeMasterHostname;
    apiserverAddress = "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
    easyCerts = true;
    apiserver = {
      securePort = kubeMasterAPIServerPort;
      advertiseAddress = kubeMasterIP;
      allowPrivileged = true;
    };

    # Addons
    addons.dns.enable = true; # use coredns

    # needed if you use swap
    kubelet.extraOpts = "--fail-swap-on=false";
  };

  # networking = {
  #   bridges = {
  #     cbr0.interfaces = [ ];
  #   };
  #   interfaces = {
  #     cbr0.ipv4.addresses = [{
  #       address = "10.10.0.1";
  #       prefixLength = 24;
  #     }];
  #   };
  # };
  # networking.nameservers = [ "10.10.0.1" ];

}
