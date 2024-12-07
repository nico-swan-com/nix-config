{ config, lib, inputs, ... }:
{
  sops = {
    secrets = {
      "users/deployer/private-key" = {
        path = lib.optionalString (lib.hasAttr "sops-nix" inputs) config.sops.secrets."users/deployer/private-key".path;
      };
    };
  };
}
