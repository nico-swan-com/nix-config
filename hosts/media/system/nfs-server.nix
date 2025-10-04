{ config, lib, pkgs, ... }: {

  boot.supportedFilesystems = [ "nfs" ];
  services.rpcbind.enable = true;

  systemd.tmpfiles.rules = [
    "d /export 0755 nobody nogroup"
    "d /mnt/ntfs_drive/wetink/pretoria 0777 nobody nogroup"
    "d /mnt/ntfs_drive/wetink/capetown 0777 nobody nogroup"
    "d /mnt/ntfs_drive/wetink/backups 0777 nobody nogroup"
  ];

  fileSystems."/export/media" = {
    device = "/mnt/export/media";
    options = [ "bind" ];
  };

  fileSystems."/export/media-storage" = {
    device = "/mnt/media-storage";
    options = [ "bind" ];
  };

  fileSystems."/export/ntfs_drive" = {
    device = "/mnt/ntfs_drive";
    options = [ "bind" ];
  };

  fileSystems."/wetink/backups" = {
    device = "/mnt/ntfs_drive/wetink/backups";
    options = [ "bind" ];
  };

  fileSystems."/wetink/pretoria" = {
    device = "/mnt/ntfs_drive/wetink/pretoria";
    options = [ "bind" ];
  };

  fileSystems."/wetink/capetown" = {
    device = "/mnt/ntfs_drive/wetink/capetown";
    options = [ "bind" ];
  };

  services.nfs.server = {
    enable = true;
    lockdPort = 4001;
    mountdPort = 4002;
    statdPort = 4000;
  };

  services.nfs.server.exports = ''
    /export               192.168.1.0/24(rw,fsid=0,no_subtree_check) 102.33.35.54(rw,fsid=0,no_subtree_check) 102.135.163.95(rw,fsid=0,no_subtree_check) 169.239.182.94(rw,fsid=0,no_subtree_check)
    /wetink/pretoria      169.239.182.94(rw,no_root_squash,no_subtree_check)
    /wetink/capetown      169.239.182.94(rw,no_root_squash,no_subtree_check)
    /wetink/backup        169.239.182.94(rw,no_root_squash,no_subtree_check) 
  '';

}

