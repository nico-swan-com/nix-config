{ config, lib, pkgs, inputs, ... }: {
  home.packages = with pkgs.unstable; [ gcc neovim ];

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

