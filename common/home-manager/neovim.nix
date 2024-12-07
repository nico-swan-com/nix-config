{ config, lib, pkgs, inputs, ... }: {
  home.packages = with pkgs.unstable; [
    neovim
    wget
    gcc
    fish
    vimPlugins.vim-markdown-toc
    markdownlint-cli2
    prettierd
    sqlfluff
    viu
    chafa
    ueberzugpp
    #
    cargo
    python3
  ];

  #  home.activation.copy-nvim-config =
  #    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #
  #      #mv ${config.home.homeDirectory}/.config/nvim ${config.home.homeDirectory}/.config/nvim.bak 
  #
  #      mkdir -p ${config.home.homeDirectory}/.config/nvim
  #
  #      cp -rn ${inputs.nicoswan-nvim-config}/* ${config.home.homeDirectory}/.config/nvim/
  #    '';
}

