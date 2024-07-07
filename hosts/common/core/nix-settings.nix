{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      # Necessary for using flakes on this system.
      experimental-features = "nix-command flakes";

      # Add needed system-features to the nix daemon
      # Starting with Nix 2.19, this will be automatic
      system-features = [
        "big-parallel"
        "kvm"
        "nixos-test"
      ];

      auto-optimise-store = true;
    };
  };
}
