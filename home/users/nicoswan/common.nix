{

  imports = [
    ../common.nix
    ../../../modules/read-aloud/read-aloud.nix
  ];

  gnome-read-aloud.enable = true;

  programs.zsh = {
    shellAliases = {
      nix-shell = "nix-shell --run zsh";
    };
  };

}
