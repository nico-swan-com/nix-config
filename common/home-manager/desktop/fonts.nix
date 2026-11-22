{ pkgs, ... }: {
  home.packages = [
    pkgs.noto-fonts
    pkgs.noto-fonts-color-emoji
    # pkgs.nerdfonts # loads the complete collection. look into overide for FiraMono or potentially mononoki
    pkgs.meslo-lgs-nf
    pkgs.nerd-fonts.fira-code
    # Fallback for any icon not covered by a specific patched font
    pkgs.nerd-fonts.symbols-only
  ];
}
