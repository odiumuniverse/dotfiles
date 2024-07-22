return {
  -- Lazy
  {
    "olimorris/onedarkpro.nvim",
    priority = 3000, -- Ensure it loads first
    config = function()
      -- Optionally configure and load the colorscheme
      -- directly inside the plugin declaration.
      vim.cmd.colorscheme("onelight")
    end,
  },
}
