# Example RustFS configurations for different deployment modes
# This file demonstrates how to use the RustFS NixOS module

{ config, pkgs, ... }:

{
  # Import the RustFS module
  imports = [ ./rustfs.nix ];

  # Example 1: Single Node Single Disk (SNSD) - Simplest deployment
  services.rustfs = {
    enable = true;
    deploymentMode = "snsd";
    address = "0.0.0.0";
    port = 9000;
    dataDir = "/data/rustfs";
    accessKey = "rustfsadmin";
    secretKey = "rustfsadmin";
    console.enable = true;
    logLevel = "info";
  };

  # Example 2: Single Node Multiple Disk (SNMD) - Better performance and redundancy
  # services.rustfs = {
  #   enable = true;
  #   deploymentMode = "snmd";
  #   address = "0.0.0.0";
  #   port = 9000;
  #   dataDirs = [ "/data/rustfs0" "/data/rustfs1" "/data/rustfs2" "/data/rustfs3" ];
  #   accessKey = "rustfsadmin";
  #   secretKey = "rustfsadmin";
  #   console.enable = true;
  #   logLevel = "info";
  #   erasureCoding = {
  #     dataBlocks = 12;
  #     parityBlocks = 4;
  #   };
  # };

  # Example 3: Multiple Node Multiple Disk (MNMD) - Production cluster
  # services.rustfs = {
  #   enable = true;
  #   deploymentMode = "mnmd";
  #   address = "0.0.0.0";
  #   port = 9000;
  #   dataDirs = [ "/data/rustfs0" "/data/rustfs1" "/data/rustfs2" "/data/rustfs3" ];
  #   nodes = [ "node1" "node2" "node3" "node4" ];
  #   accessKey = "rustfsadmin";
  #   secretKey = "rustfsadmin";
  #   console.enable = true;
  #   logLevel = "info";
  #   erasureCoding = {
  #     dataBlocks = 12;
  #     parityBlocks = 4;
  #   };
  # };

  # Example 4: With TLS encryption
  # services.rustfs = {
  #   enable = true;
  #   deploymentMode = "snsd";
  #   address = "0.0.0.0";
  #   port = 9000;
  #   dataDir = "/data/rustfs";
  #   accessKey = "rustfsadmin";
  #   secretKey = "rustfsadmin";
  #   console.enable = true;
  #   logLevel = "info";
  #   tls = {
  #     enable = true;
  #     certFile = "/opt/tls/public.crt";
  #     keyFile = "/opt/tls/private.key";
  #   };
  # };

  # Example 5: With custom systemd configuration
  # services.rustfs = {
  #   enable = true;
  #   deploymentMode = "snsd";
  #   address = "0.0.0.0";
  #   port = 9000;
  #   dataDir = "/data/rustfs";
  #   accessKey = "rustfsadmin";
  #   secretKey = "rustfsadmin";
  #   console.enable = true;
  #   logLevel = "info";
  #   systemd.extraConfig = ''
  #     # Custom systemd configuration
  #     Environment="RUSTFS_CUSTOM_VAR=value"
  #   '';
  # };

  # Required for RustFS to work properly
  # Make sure to format your data disks with XFS filesystem
  # Example for /dev/sdb:
  # sudo mkfs.xfs -i size=512 -n ftype=1 -L RUSTFS0 /dev/sdb
  # 
  # Add to /etc/fstab:
  # LABEL=RUSTFS0 /data/rustfs0 xfs defaults,noatime,nodiratime 0 0
  # 
  # Then mount:
  # sudo mount -a
}
