{
  imports = [

    # Fonts (Nerd Fonts + fallbacks for terminal icons)
    ./fonts.nix

    # Desktop applications
    ./terminals
    ./applications/cryptomator.nix

    # Software Development
    #../../common/optional/desktop/applications/vscode.nix

  ];
}
