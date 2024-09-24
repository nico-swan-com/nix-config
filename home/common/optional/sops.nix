# home level sops. see hosts/common/optional/sops.nix for hosts level

{ inputs, lib, config, ... }:
let
  secretsDirectory = builtins.toString inputs.nix-secrets;
  secretsFile = "${secretsDirectory}/secrets.yaml";
  clusterAdminSecretsFile = "${secretsDirectory}/cluster-admin-secrets.yaml";
  homeDirectory = config.home.homeDirectory;
in
{

  sops.age.keyFile = "${homeDirectory}/.config/sops/age/keys.txt";
  sops.defaultSopsFile = secretsFile;
  sops.validateSopsFiles = true;
  #sops.defaultSymlinkPath = "/run/user/1000/secrets";
  #sops.defaultSecretsMountPoint = "/run/user/1000/secrets.d";


  sops.secrets = {
    "host/private-key" = {
      sopsFile = "${secretsFile}";
      path = "${homeDirectory}/.ssh/id_host-private-key";
    };
    "ca.pem" = {
      sopsFile = "${clusterAdminSecretsFile}";
      path = "${homeDirectory}/.kube/ca.pem";
    };
    "cluster-admin.pem" = {
      sopsFile = "${clusterAdminSecretsFile}";
      path = "${homeDirectory}/.kube/cluster-admin.pem";
    };
    "cluster-admin-key.pem" = {
      sopsFile = "${clusterAdminSecretsFile}";
      path = "${homeDirectory}/.kube/cluster-admin-key.pem";
    };

  };

  home.activation.updateSecrets = ''
    /run/current-system/sw/bin/systemctl --user restart sops-nix
  '';



}
