{ pkgs, ... }:
{

  fileSystems."/mnt/home/media" = {
    device = "home.nicoswan.com:/export/media";
    fsType = "nfs";
  };

  fileSystems."/mnt/home/media-storage" = {
    device = "home.nicoswan.com:/export/media-storage";
    fsType = "nfs";
  };

  fileSystems."/mnt/home/ntfs_drive" = {
    device = "home.nicoswan.com:/export/ntfs_drive";
    fsType = "nfs";
  };

  environment.systemPackages = with pkgs; [
    nfs-utils
  ];
}
