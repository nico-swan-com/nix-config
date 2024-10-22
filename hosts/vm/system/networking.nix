{ lib, cfg, ... }:
{

  networking = {
    hostName = "${cfg.hostname}";
    domain = "nicoswan.com";

    # Enable networking
    # networkmanager.enable = true;
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    useDHCP = lib.mkDefault false;
    interfaces.eth0.useDHCP = lib.mkDefault false;
    interfaces.eth0.ipv4 = {
      addresses = [{ address = "192.168.1.101"; prefixLength = 24; }];
    };
    # interfaces.enp0s31f6.useDHCP = lib.mkDefault true;
    # interfaces.wlp2s0.useDHCP = lib.mkDefault false;
    # interfaces.wlp2s0.ipv4 = {
    #   addresses = [{ address = IPAddress; prefixLength = 24; }];
    # };

    # Open ports in the firewall.
    # firewall.allowedTCPPorts = [ ... ];
    # firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    firewall.enable = false;
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

}
