return {
  "stevearc/conform.nvim",
  formatters_by_ft = {
    go = { "gopls" },
  },
  formatters = {
    gopls = {
      prepend_args = { '-style="{IndentWidth: 4}"' },
    },
  },
}
