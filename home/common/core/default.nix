{ pkgs, configVars, ... }: {

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.stateVersion = configVars.stateVersion;

  imports = [
    ./git.nix
    ./direnv.nix
    ./zsh.nix
    ./starship.nix
  ];

  home.shellAliases = {
    la = "eza  --long -a --group-directories-first --icons=always --color=auto --almost-all --time-style=long-iso";
    ll = "la --long --no-user --no-time --no-permissions --no-filesize";
    cat = "bat -p";
    grep = "grep --color=auto";
    egrep = "egrep --color=auto";
    fgrep = "fgrep --color=auto";
  };


  home.packages = with pkgs; [
    # terminal file managers
    mc

    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder
    bat # a cat replacement
    # ncdu # disk usage uitls   
    tldr # man page replacement
    dust # disk utilization tool
    #rmlint # remove duplicate file
    #rsync # fast copy
    #rclone # fast copy to cloud providers like minio
    #ntfy # terminal notification 


    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc # it is a calculator for the IPv4/v6 addresses

    # misc
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor
    nixd # nix language server

    # productivity
    glow # markdown previewer in terminal

    btop # replacement of htop/nmon
    #iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    #strace # system call monitoring
    #ltrace # library call monitoring
    lsof # list open files

    # system tools
    #sysstat
    #lm_sensors # for `sensors` command
    #ethtool
    pciutils # lspci
    #usbutils # lsusb

    lnav

    kns #Kubernetes namespace switcher



  ];



}
