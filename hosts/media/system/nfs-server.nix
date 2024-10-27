{ config, lib, pkgs, ... }:
{

  boot.supportedFilesystems = [ "nfs" ];
  services.rpcbind.enable = true;

  systemd.tmpfiles.rules = [
    "d /export 0755 nobody nogroup"
  ];

  fileSystems."/export/media" = {
    device = "/mnt/export/media";
    options = [ "bind" ];
  };

  services.nfs.server = {
    enable = true;
    lockdPort = 4001;
    mountdPort = 4002;
    statdPort = 4000;
  };
  services.nfs.server.exports = ''
    /export               192.168.1.0/24(rw,fsid=0,no_subtree_check) 102.33.35.54(rw,fsid=0,no_subtree_check) 102.135.163.95(rw,fsid=0,no_subtree_check)
    /export/media         192.168.1.0/24(rw,fsid=0,no_subtree_check) 102.33.35.54(rw,fsid=0,no_subtree_check) 102.135.163.95(rw,fsid=0,no_subtree_check)
  '';

}

