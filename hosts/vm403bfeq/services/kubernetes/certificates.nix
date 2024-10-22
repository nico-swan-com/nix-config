{ pkgs, lib, inputs, cfg, ... }:
{
  sops = {
    secrets = {
      "ca.pem" = { sopsFile = ./certificates.yaml; mode = "0644"; path = "/var/lib/kubernetes/secrets/ca.pem"; };
      "cluster-admin-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600"; path = "/var/lib/kubernetes/secrets/cluster-admin-key.pem"; };
      "cluster-admin.pem" = { sopsFile = ./certificates.yaml; mode = "0644"; path = "/var/lib/kubernetes/secrets/cluster-admin.pem"; };
      "etcd-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600"; path = "/var/lib/kubernetes/secrets/etcd-key.pem"; };
      "etcd.pem" = { sopsFile = ./certificates.yaml; mode = "0644"; path = "/var/lib/kubernetes/secrets/etcd.pem"; };
      "flannel-client-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600"; path = "/var/lib/kubernetes/secrets/flannel-client-key.pem"; };
      "flannel-client.pem" = { sopsFile = ./certificates.yaml; mode = "0644"; path = "/var/lib/kubernetes/secrets/flannel-client.pem"; };
      "kube-addon-manager-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600"; path = "/var/lib/kubernetes/secrets/kube-addon-manager-key.pem"; };
      "kube-addon-manager.pem" = { sopsFile = ./certificates.yaml; mode = "0644"; path = "/var/lib/kubernetes/secrets/kube-addon-manager.pem"; };
      "kube-apiserver-etcd-client-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600"; path = "/var/lib/kubernetes/secrets/kube-apiserver-etcd-client-key.pem"; };
      "kube-apiserver-etcd-client.pem" = { sopsFile = ./certificates.yaml; mode = "0644"; path = "/var/lib/kubernetes/secrets/kube-apiserver-etcd-client.pem"; };
      "kube-apiserver-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600"; path = "/var/lib/kubernetes/secrets/kube-apiserver-key.pem"; };
      "kube-apiserver-kubelet-client-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600"; path = "/var/lib/kubernetes/secrets/kube-apiserver-kubelet-client-key.pem"; };
      "kube-apiserver-kubelet-client.pem" = { sopsFile = ./certificates.yaml; mode = "0644"; path = "/var/lib/kubernetes/secrets/kube-apiserver-kubelet-client.pem"; };
      "kube-apiserver.pem" = { sopsFile = ./certificates.yaml; mode = "0644"; path = "/var/lib/kubernetes/secrets/kube-apiserver.pem"; };
      "kube-apiserver-proxy-client-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600"; path = "/var/lib/kubernetes/secrets/kube-apiserver-proxy-client-key.pem"; };
      "kube-apiserver-proxy-client.pem" = { sopsFile = ./certificates.yaml; mode = "0644"; path = "/var/lib/kubernetes/secrets/kube-apiserver-proxy-client.pem"; };
      "kube-controller-manager-client-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600"; path = "/var/lib/kubernetes/secrets/kube-controller-manager-client-key.pem"; };
      "kube-controller-manager-client.pem" = { sopsFile = ./certificates.yaml; mode = "0644"; path = "/var/lib/kubernetes/secrets/kube-controller-manager-client.pem"; };
      "kube-controller-manager-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600"; path = "/var/lib/kubernetes/secrets/kube-controller-manager-key.pem"; };
      "kube-controller-manager.pem" = { sopsFile = ./certificates.yaml; mode = "0644"; path = "/var/lib/kubernetes/secrets/kube-controller-manager.pem"; };
      "kubelet-client-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600"; path = "/var/lib/kubernetes/secrets/kubelet-client-key.pem"; };
      "kubelet-client.pem" = { sopsFile = ./certificates.yaml; mode = "0644"; path = "/var/lib/kubernetes/secrets/kubelet-client.pem"; };
      "kubelet-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600"; path = "/var/lib/kubernetes/secrets/kubelet-key.pem"; };
      "kubelet.pem" = { sopsFile = ./certificates.yaml; mode = "0644"; path = "/var/lib/kubernetes/secrets/kubelet.pem"; };
      "kube-proxy-client-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600"; path = "/var/lib/kubernetes/secrets/kube-proxy-client-key.pem"; };
      "kube-proxy-client.pem" = { sopsFile = ./certificates.yaml; mode = "0644"; path = "/var/lib/kubernetes/secrets/kube-proxy-client.pem"; };
      "kube-scheduler-client-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600"; path = "/var/lib/kubernetes/secrets/kube-scheduler-client-key.pem"; };
      "kube-scheduler-client.pem" = { sopsFile = ./certificates.yaml; mode = "0644"; path = "/var/lib/kubernetes/secrets/kube-scheduler-client.pem"; };
      "service-account-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600"; path = "/var/lib/kubernetes/secrets/service-account-key.pem"; };
      "service-account.pem" = { sopsFile = ./certificates.yaml; mode = "0644"; path = "/var/lib/kubernetes/secrets/service-account.pem"; };
      # "ca.pem" = { sopsFile = ./certificates.yaml; mode = "0644"; };
      # "cluster-admin-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600";  };
      # "cluster-admin.pem" = { sopsFile = ./certificates.yaml; mode = "0644"; };
      # "etcd-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600";  };
      # "etcd.pem" = { sopsFile = ./certificates.yaml; mode = "0644";  };
      # "flannel-client-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600";  };
      # "flannel-client.pem" = { sopsFile = ./certificates.yaml; mode = "0644";  };
      # "kube-addon-manager-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600"; };
      # "kube-addon-manager.pem" = { sopsFile = ./certificates.yaml; mode = "0644";  };
      # "kube-apiserver-etcd-client-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600";  };
      # "kube-apiserver-etcd-client.pem" = { sopsFile = ./certificates.yaml; mode = "0644";  };
      # "kube-apiserver-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600"; };
      # "kube-apiserver-kubelet-client-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600";  };
      # "kube-apiserver-kubelet-client.pem" = { sopsFile = ./certificates.yaml; mode = "0644";  };
      # "kube-apiserver.pem" = { sopsFile = ./certificates.yaml; mode = "0644";  };
      # "kube-apiserver-proxy-client-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600";  };
      # "kube-apiserver-proxy-client.pem" = { sopsFile = ./certificates.yaml; mode = "0644";  };
      # "kube-controller-manager-client-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600";  };
      # "kube-controller-manager-client.pem" = { sopsFile = ./certificates.yaml; mode = "0644"; };
      # "kube-controller-manager-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600"; };
      # "kube-controller-manager.pem" = { sopsFile = ./certificates.yaml; mode = "0644"; };
      # "kubelet-client-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600";  };
      # "kubelet-client.pem" = { sopsFile = ./certificates.yaml; mode = "0644"; };
      # "kubelet-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600"; };
      # "kubelet.pem" = { sopsFile = ./certificates.yaml; mode = "0644";  };
      # "kube-proxy-client-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600";  };
      # "kube-proxy-client.pem" = { sopsFile = ./certificates.yaml; mode = "0644";  };
      # "kube-scheduler-client-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600";  };
      # "kube-scheduler-client.pem" = { sopsFile = ./certificates.yaml; mode = "0644";  };
      # "service-account-key.pem" = { sopsFile = ./certificates.yaml; mode = "0600";  };
      # "service-account.pem" = { sopsFile = ./certificates.yaml; mode = "0644"; };
    };
  };

  #  services.kubernetes = {
  #     # secretsPath
  #     caFile = lib.mkDefault config.secrets."ca.pem".path;
  #     apiserver = {
  #       # tokenAuthFile
  #       # tlsKeyFile
  #       # tlsCertFile
  #       # serviceAccountSigningKeyFile
  #       # serviceAccountKeyFile
  #       # proxyClientKeyFile
  #       # proxyClientCertFile
  #       # kubeletClientKeyFile
  #       # kubeletClientCertFile
  #       # kubeletClientCaFile
  #       # etcd.keyFile
  #       # etcd.certFile
  #       # etcd.caFile
  #       # clientCaFile
  #     };

  #     kubelet = {
  #       # tlsKeyFile
  #       # tlsCertFile
  #       # kubeconfig.keyFile
  #       # kubeconfig.certFile
  #       # kubeconfig.caFile
  #       # clientCaFile
  #     };

  #     kubeconfig = {
  #       #server
  #       #caFile = caFile;
  #       #certFile = certFile;
  #       #keyFile = keyFile;
  #     };

  #     # scheduler = {
  #     #   kubeconfig = {
  #     #     server
  #     #     keyFile
  #     #     certFile
  #     #     caFile
  #     #   };
  #     # };

  #     # proxy = {
  #     #   kubeconfig = {
  #     #     server
  #     #     keyFile
  #     #     certFile
  #     #     caFile
  #     #   }
  #     # };
  #     pki = {
  #       pkiTrustOnBootstrap = false;
  #       genCfsslCACert = false;
  #       genCfsslAPIToken = false;
  #        genCfsslAPICerts = false;
  #     #   etcClusterAdminKubeconfig
  #     #    enable
  #     #    cfsslAPIExtraSANs
  #     #    certs
  #     #    caSpec
  #     #    caCertPathPrefix
  #     }

  #     controllerManager = {
  #     #   tlsKeyFile
  #     #   tlsCertFile
  #     #   serviceAccountKeyFile
  #     #   rootCaFile
  #     #   kubeconfig.keyFile
  #     #   kubeconfig.certFile
  #     #   kubeconfig.caFile
  #     };
}
