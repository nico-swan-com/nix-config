{

  # Open ports in the firewall.
   networking.firewall.enable = false;
  # networking.firewall = {
  #    allowedTCPPorts = [ 80 443 22 6443 5432 8888 111 4000 4001 4002 20048 5000 8153 8154  8080];
  #    extraCommands = ''
  #       iptables -I INPUT 1 -i docker0 -p tcp -d 172.17.0.1 -j ACCEPT
  #       iptables -I INPUT 2 -i docker0 -p udp -d 172.17.0.1 -j ACCEPT
  #     '';
  # };

  # Enable networking
  networking.networkmanager.enable = true;
  networking.useDHCP = false; # lib.mkDefault true;
  networking.interfaces.ens18.ipv4.addresses = [{
    address = "102.135.163.95";
    prefixLength = 24;
  }];
  networking.defaultGateway = "102.135.163.1";
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];
  networking.hostName = "vm403bfeq"; # Define your hostname.
  networking.domain = "cygnus-labs.com";

  # Enable NAT for containers
  #networking.nat.enable = true;
  #networking.nat.internalInterfaces = ["ve-+"];
  #networking.nat.externalInterface = "ens18";

}
