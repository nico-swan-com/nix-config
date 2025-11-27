{ pkgs, ... }: {
  imports = [
    ./system-packages.nix
    ./users
  ];

  system.stateVersion = "25.11";
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "beekeeper-studio-5.3.4"  # Electron 31 is EOL, but package is still useful
    ];
  };

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      interactiveShellInit = ''
        source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
        bindkey '^[OA' history-substring-search-up
        bindkey '^[[A' history-substring-search-up
        bindkey '^[OB' history-substring-search-down
        bindkey '^[[B' history-substring-search-down
      '';
    };
    fzf = {
      fuzzyCompletion = true;
      keybindings = true;
    };
  };
}
