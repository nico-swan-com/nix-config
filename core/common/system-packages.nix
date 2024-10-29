{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    zsh
    vim
    sops
    just
    nil

    # nix
    nix-output-monitor  # it provides the command `nom` works just like `nix` with more details log output
    nixd
    nixpkgs-fmt
    nixfmt-classic

    # archives
    zip
    xz
    unzip
    p7zip

    # terminal file managers
    mc

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder
    bat # a cat replacement
    tldr # man page replacement
    dust # disk utilization tool
    btop # replacement of htop/nmon
    
    lsof # list open files

    # networking tools
    # iftop # network monitoring
    # dnsutils # `dig` + `nslookup`



    # misc
    # file
    # which
    tree
    # gnused
    # gnutar
    # gawk
    # zstd
    # gnupg

  ];

}
