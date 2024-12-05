-- lunarvim-config.lua
-- This is a basic configuration file for LunarVim

-- General settings
vim.opt.number = true           -- Show line numbers
vim.opt.relativenumber = true   -- Relative line numbers
vim.opt.hlsearch = true         -- Highlight search results
vim.opt.incsearch = true        -- Incremental search
vim.opt.wrap = false            -- Disable line wrapping

-- Colorscheme
vim.cmd("colorscheme gruvbox")

-- Plugins
require("lvim.plugins").setup({
  {
    "morhetz/gruvbox",
    event = "VimEnter",
    config = function()
      vim.cmd("colorscheme gruvbox")
    end,
  },
})

-- Key mappings
vim.api.nvim_set_keymap("n", "<Space>", "", { noremap = true, silent = true })
vim.g.mapleader = " "

-- Custom settings
lvim.leader = "space"
lvim.keys.normal_mode["<C-s>"] = ":w<CR>"

-- Additional plugins
lvim.plugins = {
  "folke/tokyonight.nvim",
  "nvim-lua/plenary.nvim",
  "nvim-telescope/telescope.nvim",
}


