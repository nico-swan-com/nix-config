{

  imports = [
    ../common.nix
  ];

  programs.zsh = {
    shellAliases = {
      nix-shell = "nix-shell --run zsh";
    };
  };

}
