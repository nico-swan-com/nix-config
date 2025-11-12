{ inputs, pkgs, ... }: {
  # Bootloader
  boot.plymouth.enable = true;
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      enable = false;
      configurationLimit = 3;
    };
    grub = {
      enable = true;
      device = "nodev";
      useOSProber = true;
      efiSupport = true;
      configurationLimit = 5; # Reduced from 10 to save space
      copyKernels = false;
      fsIdentifier = "label";
      #splashImage = ./backgrounds/grub-nixos-3.png;
      #splashMode = "stretch";

      #theme = inputs.distro-grub-themes.packages..<theme_name>-grub-theme;
      #splashImage = "${theme}/splash_image.jpg";

      #theme = pkgs.stdenv.mkDerivation {
      #  pname = "distro-grub-themes";
      #  version = "3.1";
      #  src = pkgs.fetchFromGitHub {
      #    owner = "AdisonCavani";
      #    repo = "distro-grub-themes";
      #    rev = "v3.1";
      #    hash = "sha256-ZcoGbbOMDDwjLhsvs77C7G7vINQnprdfI37a9ccrmPs=";
      #  };
      #  installPhase = "cp -r customize/nixos $out";
      #};
    };
  };

  distro-grub-themes = {
    enable = true;
    #theme = "<theme_name>";
  };

}
