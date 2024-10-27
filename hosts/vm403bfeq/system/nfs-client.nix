{ pkgs, ... }:
{

  fileSystems."/mnt/home" = {
    device = "home.nicoswan.com:/export";
    fsType = "nfs";
  };

  environment.systemPackages = with pkgs; [
    nfs-utils
  ];

  
} 
