{ lib, ... }:
{
  networking = {
    hostName = "asus-laptop";
    domain = "nicoswan.com";

    # Enable networking
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;
    interfaces.wlp2s0.useDHCP = lib.mkDefault true;
    firewall = {
      enable = false;
      # Kept ready in case firewall is enabled later (Paperclip :3100, T3 Code :3773).
      allowedTCPPorts = [
        3100
        3773
      ];
    };
  };

  # Advertise asus-laptop.local on LAN via mDNS so Paperclip & T3 Code can be
  # reached by hostname from other devices without tracking DHCP IP changes.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      workstation = true;
    };
  };
}
