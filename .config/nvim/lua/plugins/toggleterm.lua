return {
  "akinsho/toggleterm.nvim",
  lazy = false,
  config = function()
    require("toggleterm").setup({
      float_opts = {
        border = "curved",
        title_pos = "left",
      },
    })
  end,
}
