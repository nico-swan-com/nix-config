# RustFS object storage service for dell-laptop
# Simple configuration using systemd service instead of complex module

{ config, pkgs, ... }:

{
  # RustFS systemd service configuration
  systemd.services.rustfs = {
    enable = true;
    description = "RustFS Object Storage Server";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    
    serviceConfig = {
      Type = "simple";
      User = "rustfs";
      Group = "rustfs";
      WorkingDirectory = "/data/rustfs";
      ExecStart = "${pkgs.rustfs}/bin/rustfs server --data-dir /data/rustfs --address 0.0.0.0:9000";
      Restart = "always";
      RestartSec = "10s";
    };
    
    wantedBy = [ "multi-user.target" ];
  };

  # Create rustfs user and group
  users.users.rustfs = {
    isSystemUser = true;
    group = "rustfs";
    description = "RustFS object storage service user";
  };

  users.groups.rustfs = {};

  # Create data directory
  systemd.tmpfiles.rules = [
    "d /data/rustfs 0750 rustfs rustfs"
  ];

  # Firewall configuration
  networking.firewall = {
    allowedTCPPorts = [ 9000 ];
  };

  # Environment packages
  environment.systemPackages = [ pkgs.rustfs ];
}
