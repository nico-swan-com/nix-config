{ lib, ... }:
let IPAddress = "192.168.1.100";
in {

  networking = {
    hostName = "dell-laptop";
    domain = "nicoswan.com";

    # Enable networking
    networkmanager.enable = true;
    #networkmanager.dns = "dnsmasq";
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    useDHCP = lib.mkDefault false;
    interfaces.wlp2s0.useDHCP = lib.mkDefault false;
    interfaces.wlp2s0.ipv4 = {
      addresses = [{
        address = IPAddress;
        prefixLength = 24;
      }];
    };
    nameservers = [ "1.1.1.1" "1.0.0.1" ];

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    firewall.enable = false;
    hosts = {
      "192.168.1.90" = [ "pi-cluster-1.local" ];
      "192.168.1.91" = [ "pi-cluster-2.local" ];
      "192.168.1.92" = [ "pi-cluster-3.local" ];
    };
  };

  #services.dnsmasq = {
  #  enable = true;
  #  settings = { address = [ "/*.pi-cluster.nicoswan.com/192.168.1.90" ]; };
  #};
}
