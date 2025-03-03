{ inputs, lib, ... }: {
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
