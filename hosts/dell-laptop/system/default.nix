{
  imports = [
    ./hardware-configuration.nix
    ./boot-loader.nix
    ./xserver.nix
    ./sound.nix
    ./networking.nix
    ./dell-5490.nix
    ./gnome-desktop.nix
    ./nfs-client.nix
    #./egpu.nix
    ./nix-settings.nix
  ];

  # Power button invokes suspend, not shutdown.

  #services.logind = {
  #
  #  extraConfig = "HandlePowerKey=suspend";
  #
  #  lidSwitch = "suspend";
  #
  #};

  # Enable CUPS to print documents.
  # services.printing.enable = true;
}
