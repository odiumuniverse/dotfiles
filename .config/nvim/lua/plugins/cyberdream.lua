return {
  {
    "scottmckendry/cyberdream.nvim",
    lazy = true,
    opts = {
      italic_comments = true,
      transparent = true,
      hide_fillchars = true,
      borderless_pickers = true,
    },
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "cyberdream" } },
  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", name = "catppuccin", enabled = false },
}
