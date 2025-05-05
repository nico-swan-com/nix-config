{ pkgs, ... }: {
  home.packages = [
    pkgs.noto-fonts
    # pkgs.nerdfonts # loads the complete collection. look into overide for FiraMono or potentially mononoki
    pkgs.meslo-lgs-nf
    pkgs.nerd-fonts.fira-code
  ];
}
