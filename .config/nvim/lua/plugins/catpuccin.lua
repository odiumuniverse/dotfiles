return {
  "catppuccin/nvim",
    lazy = false,
    priority = 3000,
    config = function()
      vim.cmd("colorscheme catppuccin")
    end,
}
