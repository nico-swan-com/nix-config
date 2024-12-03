{ config, pkgs, lib, ... }:
let
  # When using easyCerts=true the IP Address must resolve to the master on creation.
  # So use simply 127.0.0.1 in that case. Otherwise you will have errors like this https://github.com/NixOS/nixpkgs/issues/59364
  kubeMasterIP = "102.135.163.95";
  kubeMasterHostname = "vm403bfeq.cygnus-labs.com";
  kubeMasterAPIServerPort = 6443;

  # keyFile = "${config.sops.secrets."servers/cygnus-labs/kubernetes/keyFile".path}";
  # certFile = "${config.sops.secrets."servers/cygnus-labs/kubernetes/certFile".path}";
  # caFile = "${config.sops.secrets."servers/cygnus-labs/kubernetes/caFile".path}";

in
{


  # resolve master hostname
  networking.extraHosts = "${kubeMasterIP} ${kubeMasterHostname}";

  # packages for administration tasks
  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes
    openiscsi
    nfs-utils
    cifs-utils
    cryptsetup
    lvm2
  ];

  # Fixes for longhorn
  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
    "d /data/openebs/local 0755 root root"
  ];
  #virtualisation.docker.logDriver = "json-file";

  services.openiscsi = {
    enable = true;
    name = "iqn.2016-04.com.open-iscsi:${config.networking.hostName}";
  };

  services.kubernetes = {
    roles = [ "master" "node" ];
    masterAddress = kubeMasterHostname;
    apiserverAddress = "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
    easyCerts = true;
    # caFile = lib.mkDefault caFile;
    # path
    # secretsPath 
    # package
    # lib
    # featureGates
    # dataDir
    # clusterCidr
    # caFile
    # apiserverAddress

    apiserver = {
      securePort = kubeMasterAPIServerPort;
      advertiseAddress = kubeMasterIP;
      allowPrivileged = true;
      # webhookConfig
      # verbosity
      # tokenAuthFile
      # tlsKeyFile
      # tlsCertFile
      # storageBackend
      # serviceClusterIpRange
      # serviceAccountSigningKeyFile
      # serviceAccountKeyFile
      # serviceAccountIssuer
      # securePort
      # runtimeConfig
      # proxyClientKeyFile
      # proxyClientCertFile
      # preferredAddressTypes
      # kubeletClientKeyFile
      # kubeletClientCertFile
      # kubeletClientCaFile
      # featureGates
      # extraSANs
      # extraOpts
      # etcd.servers
      # etcd.keyFile
      # etcd.certFile
      # etcd.caFile
      # enableAdmissionPlugins
      # enable
      # disableAdmissionPlugins
      # clientCaFile
      # bindAddress
      # basicAuthFile
      # authorizationPolicy
      # authorizationMode
      # apiAudiences
      # allowPrivileged
      # advertiseAddress
    };

    # Addons
    addons.dns = {
      enable = true; # use coredns
      # replicas
      # reconcileMode
      # enable
      # corefile
      # coredns
      # clusterIp
      # clusterDomain = "cluster.private";
    };

    kubelet = {
      # verbosity
      # unschedulable
      # tlsKeyFile
      # tlsCertFile
      # taints.<name>.value
      # taints.<name>.key
      # taints.<name>.effect
      # taints
      # seedDockerImages
      # registerNode
      # port
      # nodeIp
      # manifests
      # kubeconfig.server
      # kubeconfig.keyFile
      # kubeconfig.certFile
      # kubeconfig.caFile
      # hostname
      # healthz.port
      # healthz.bind
      # featureGates
      # extraOpts
      # extraConfig
      # enable
      # containerRuntimeEndpoint
      # cni.packages
      # cni.configDir
      # cni.config
      # clusterDomain
      # clusterDns
      # clientCaFile
      # address
      extraOpts = ''
        --fail-swap-on=false
      '';
    };

    # kubeconfig = {
    #   #server
    #   caFile = caFile;
    #   certFile = certFile;
    #   keyFile = keyFile;
    # };

    # scheduler = {
    #   verbosity
    #   port
    #   leaderElect
    #   kubeconfig = {
    #     server
    #     keyFile
    #     certFile
    #     caFile
    #   };
    #   featureGates
    #   extraOpts
    #   enable
    #   address
    # };

    # proxy = {
    #   verbosity
    #   kubeconfig = {
    #     server
    #     keyFile
    #     certFile
    #     caFile
    #   }
    #   hostname
    #   featureGates
    #   extraOpts
    #   enable
    #   bindAddress
    # };
    # pki = {
    #    pkiTrustOnBootstrap
    #    genCfsslCACert
    #    genCfsslAPIToken
    #    genCfsslAPICerts
    #    etcClusterAdminKubeconfig
    #    enable
    #    cfsslAPIExtraSANs
    #    certs
    #    caSpec
    #    caCertPathPrefix
    # }
    # controllerManager = {
    #   verbosity
    #   tlsKeyFile
    #   tlsCertFile
    #   serviceAccountKeyFile
    #   securePort
    #   rootCaFile
    #   leaderElect
    #   kubeconfig.server
    #   kubeconfig.keyFile
    #   kubeconfig.certFile
    #   kubeconfig.caFile
    #   featureGates
    #   extraOpts
    #   enable
    #   clusterCidr
    #   bindAddress
    #   allocateNodeCIDRs
    # };
    # flannel = {
    #   enable
    #   openFirewallPorts
    # };

    # addonManager = {
    #   enable
    #   bootstrapAddons
    #   addons
    # }

  };

}
