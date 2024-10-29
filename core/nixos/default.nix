{
  imports = [
    ./system-packages.nix
    ./users
  ];

  system.stateVersion = "24.05";
  nixpkgs.config.allowUnfree = true;

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
    };
    fzf = {
      fuzzyCompletion = true;
      keybindings = true;
    };
  };
}
