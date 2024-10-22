{ pkgs, ... }: {
  home.packages = [
    pkgs.noto-fonts
    # pkgs.nerdfonts # loads the complete collection. look into overide for FiraMono or potentially mononoki
    pkgs.fira-code-nerdfont
    pkgs.meslo-lgs-nf
  ];
}
