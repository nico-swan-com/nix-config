{pkgs, ...}:
{
  imports = [
    ../common/system-packages.nix
  ];

  environment.systemPackages = with pkgs; [
    # utils
    # ncdu # disk usage uitls   
    #rmlint # remove duplicate file
    #rsync # fast copy
    #rclone # fast copy to cloud providers like minio
    #ntfy # terminal notification 

    # utils
    fswatch # watch file system events
#   git-extras # Some git extra command see https://github.com/tj/git-extras
#   ncdu # disk usage uitls   
#   rmlint # remove duplicate file
#   rsync # fast copy
#   rclone # fast copy to cloud providers like minio
#   ntfy # terminal notification 
#   iotop # io monitoring



    # networking tools
    # iftop # network monitoring
    # mtr # A network diagnostic tool
    # iperf3
    # dnsutils # `dig` + `nslookup`
    # ldns # replacement of `dig`, it provide the command `drill`
    # aria2 # A lightweight multi-protocol & multi-source command-line download utility
    # socat # replacement of openbsd-netcat
    # nmap # A utility for network discovery and security auditing
    # ipcalc # it is a calculator for the IPv4/v6 addresses


    # misc
    # file
    # which
    # tree
    # gnused
    # gnutar
    # gawk
    # zstd
    # gnupg

    # system tools
#   sysstat
#   lm_sensors # for `sensors` command
#   ethtool
#   pciutils # lspci
#   usbutils # lsusb

   # system call monitoring
#   strace # system call monitoring
#   ltrace # library call monitoring

    #Fun 
    cmatrix
  ];

}