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

  nix = {
    settings = {
      auto-optimise-store = lib.mkForce true;
      # Reduce disk usage by using hard links more efficiently
      min-free = 1000000000; # 1GB minimum free space before GC
      max-free = 5000000000; # 5GB maximum free space to keep
    };
    # Automatic store optimization (deduplication)
    optimise = {
      automatic = true;
      dates = [ "03:45" ];
    };
    # Automatic garbage collection
    gc = {
      automatic = true;
      dates = "weekly"; # Run GC weekly (can be "daily", "weekly", or specific times)
      options = "--delete-older-than 7d"; # Delete generations older than 7 days
    };
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
