{ pkgs, inputs, config, lib, ... }:
let
  gitHubTokenSecret = "users/nicoswan/access-token/gitHub";
in {
  sops.secrets = {
    ${gitHubTokenSecret} = {
      mode = "0400";
      owner = "root";
      group = "root";
    };
  };

  sops.templates."nix-github-access-tokens.conf".content = ''
    access-tokens = github.com=${config.sops.placeholder.${gitHubTokenSecret}}
  '';

  nix = {
    extraOptions = ''
      !include ${config.sops.templates."nix-github-access-tokens.conf".path}
    '';
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
