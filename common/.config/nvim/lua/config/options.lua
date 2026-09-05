-- Presse-papiers OSC 52 pour les sessions tmux / SSH / herdr, avant tout le
-- reste : options.lua est chargé avant lazy.nvim, donc vim.g.clipboard est en
-- place avant le premier yank. Voir remote_clipboard.lua à côté.
require("config.remote_clipboard").setup()

-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = true
