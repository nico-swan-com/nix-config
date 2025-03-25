{ pkgs, inputs, config, lib, ... }:
let
  accessTokenPath =
    config.sops.secrets."users/nicoswan/access-token/gitHub".path;
in {
  sops.secrets = { "users/nicoswan/access-token/gitHub" = { mode = "744"; }; };

  environment.variables = {
    NIX_CONFIG = "access-tokens = github.com:$(cat ${accessTokenPath})";
    GITHUB_TOKEN = "$(cat ${accessTokenPath})";
  };

  nix = { settings = { auto-optimise-store = lib.mkForce true; }; };
  nix.optimise = {
    automatic = true;
    dates = [ "03:45" ];
  };

  # Auto update
  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [ "-L" ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };

}
