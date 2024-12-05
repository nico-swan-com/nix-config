{inputs, lib, ... }:{

  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ./bufferlines
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    colorschemes.catppuccin.enable = true;
    plugins = {
      lualine.enable = true;
      bufferline = { enable = true; }
    };
    #custom = {
     # bufferlines.enable = true;
    #colorschemes.enable = lib.mkDefault true;
    #  completion.enable = lib.mkDefault true;
    # dap.enable = lib.mkDefault true;
    # filetrees.enable = lib.mkDefault false;
    # git.enable = lib.mkDefault true;
    # keys.enable = true;
    # languages.enable = true;
    # lsp.enable = lib.mkDefault true;
    # none-ls.enable = lib.mkDefault false;
    # sets.enable = lib.mkDefault true;
    # pluginmanagers.enable = lib.mkDefault true;
    # snippets.enable = lib.mkDefault true;
    # statusline.enable = lib.mkDefault true;
    # telescope.enable = lib.mkDefault true;
    # ui.enable = lib.mkDefault true;
    # utils.enable = lib.mkDefault true;
    #};
  };
}