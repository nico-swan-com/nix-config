{ lib, ... }:
{
  networking = {
    hostName = "asus-laptop";
    domain = "nicoswan.com";

    # Enable networking
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;
    interfaces.wlp2s0.useDHCP = lib.mkDefault true;
    firewall.enable = false;
  };
}
