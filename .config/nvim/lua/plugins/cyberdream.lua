return {
  "scottmckendry/cyberdream.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("cyberdream").setup({
      italic_comments = true,
      transparent = true,
      hide_fillchars = true,
      borderless_pickers = true,
    })

    vim.cmd("colorscheme cyberdream")
  end,
}
