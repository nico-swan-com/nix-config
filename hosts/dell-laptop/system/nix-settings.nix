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
  # Auto update
  system.autoUpgrade = {
    enable = false;
    # To see the status of the timer run
    #  systemctl status nixos-upgrade.timer

    # The upgrade log can be printed with this command
    #  systemctl status nixos-upgrade.service
    flake = inputs.self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "-L" # print build logs
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };

}
