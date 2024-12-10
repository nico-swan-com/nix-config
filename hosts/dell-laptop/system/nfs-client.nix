{ pkgs, ... }: {

  fileSystems."/mnt/cygnus-lab-export" = {
    device = "102.135.163.95:/export";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };
  fileSystems."/mnt/media" = {
    device = "home.nicoswan.com:/export";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };
  environment.systemPackages = with pkgs; [ nfs-utils ];

}
