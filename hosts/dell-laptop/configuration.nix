{ configVars, inputs, ... }:
let
  secretsDirectory = builtins.toString inputs.nix-secrets;
  cygnusLabsSecretsFile = "${secretsDirectory}/cluster-admin-secrets.yaml";
in
{
  imports =
    [
      # Core configuration
      ../common/core
      ../common/core/sops.nix
      ../common/core/locale.nix
      ../common/users

      # Include the results of the hardware scan.
      ./system

      # Services 
      ./services

      # Programs and Applications
      ./packages

    ];

  system.stateVersion = configVars.stateVersion;

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
