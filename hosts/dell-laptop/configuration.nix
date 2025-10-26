{ ... }:
# let
#   secretsDirectory = builtins.toString inputs.nix-secrets;
#   cygnusLabsSecretsFile = "${secretsDirectory}/cluster-admin-secrets.yaml";
# in
{
  imports = [
    ../../core/nixos
    ./sops.nix

    # Include the results of the hardware scan.
    ./system

    # Services
    ./services

    # Programs and Applications
    ./packages

  ];

  security.sudo.wheelNeedsPassword = false;

  programs.nix-ld.enable = true;
  home-manager.backupFileExtension = "backup";

  services.gvfs.enable = true;
  virtualisation.vmVariant = {
    # following configuration is added only when building VM with build-vm
    virtualisation = {
      memorySize = 8192;
      cores = 4;
      graphics = true;
      mountHostNixStore = true;
      sharedDirectories = {
        sops = {
          source = "/home/nicoswan/.config/sops/age";
          target = "/home/nicoswan/.config/sops/age";
          securityModel = "passthrough";
        };
      };
    };
  };

  #programs.steam = {
  #  enable = true;
  #  remotePlay.openFirewall = true; # Open ports for Steam Remote Play
  #  dedicatedServer.openFirewall =
  #    true; # Open ports for Source Dedicated Server
  #};

  # sops = {
  #   secrets = {
  #     # "ca" = {
  #     #   sopsFile = "${cygnusLabsSecretsFile}";
  #     # };
  #     # "cluster-admin.pem" = {
  #     #   sopsFile = ../../../hosts/vm403bfeq/services/kubernetes/certificates.yaml;
  #     # };
  #     # "cluster-admin-key.pem" = {
  #     #   sopsFile = ../../../hosts/vm403bfeq/services/kubernetes/certificates.yaml;
  #     # };
  #   };
  # };

}
