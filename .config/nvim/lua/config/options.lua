-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.lazyvim_picker = "fzf"
vim.g.lazyvim_cmp = "blink.cmp"
-- neocodeium shows inline suggestions instead of a blink.cmp source
vim.g.ai_cmp = false

vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.spelllang = { "en", "ru" }
