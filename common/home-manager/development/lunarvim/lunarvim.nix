{ config, pkgs, ... }: {

  home.packages = with pkgs; [
    lunarvim
    vimPlugins.neogit
  ];

}
