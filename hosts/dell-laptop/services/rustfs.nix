# RustFS object storage service for vm895mqys
# This is an example configuration - customize as needed

{ config, pkgs, ... }:

{
  # Import the RustFS module
  imports = [ ../../../../modules/rustfs/rustfs.nix ];

  # RustFS configuration
  services.rustfs = {
    enable = true;
    package = pkgs.rustfs;
    
    # Choose deployment mode based on your needs:
    # - "snsd": Single Node Single Disk (simplest)
    # - "snmd": Single Node Multiple Disk (better performance)
    # - "mnmd": Multiple Node Multiple Disk (production cluster)
    deploymentMode = "snsd";
    
    # Network configuration
    address = "0.0.0.0";
    port = 9000;
    
    # Data storage
    dataDir = "/data/rustfs";
    
    # Authentication (change these in production!)
    accessKey = "rustfsadmin";
    secretKey = "rustfsadmin";
    
    # Web console
    console = {
      enable = true;
      port = 9001;
    };
    
    # Logging
    logLevel = "info";
    
    # Optional: TLS encryption
    # tls = {
    #   enable = true;
    #   certFile = "/opt/tls/public.crt";
    #   keyFile = "/opt/tls/private.key";
    # };
    
    # Optional: Custom erasure coding settings
    # erasureCoding = {
    #   dataBlocks = 12;
    #   parityBlocks = 4;
    # };
  };

  # Ensure the data directory exists and has proper permissions
  systemd.tmpfiles.rules = [
    "d /data/rustfs 0750 rustfs rustfs"
  ];

  # Optional: If you want to use a different data directory
  # systemd.tmpfiles.rules = [
  #   "d /mnt/storage/rustfs 0750 rustfs rustfs"
  # ];
}
