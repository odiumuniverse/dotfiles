return {
  "projekt0n/github-nvim-theme",
  lazy = false, -- Make sure we load this during startup if it is your main colorscheme
  priority = 100, -- Make sure to load this before all the other start plugins
  config = function()
    require("github-theme").setup({
      options = {
        styles = {
          comments = "italic",
          types = "italic",
        },
      },
    })
  end,
}
