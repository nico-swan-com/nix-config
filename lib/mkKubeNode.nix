{ ... }:
name:
{ kubeMasterIP
, kubeMasterHostname
, kubeMasterAPIServerPort ? 6443
}: {
  # resolve master hostname
  networking.extraHosts = "${kubeMasterIP} ${kubeMasterHostname}";

  services.kubernetes = {
    roles = [ "node" ];
    masterAddress = kubeMasterHostname;

    # point kubelet and other services to kube-apiserver
    kubelet.kubeconfig.server = "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
    apiserverAddress = "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";

    kubelet.extraOpts = "--fail-swap-on=false";
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      6443
      2379
      2380
      10250
      10259
      10257
      10250
    ];
  };

  # Manually configure nameserver. Using resolved inside the container seems to fail
  # currently
  environment.etc."resolv.conf".text = "nameserver 1.1.1.1";
}
