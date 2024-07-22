return {
  "stevearc/conform.nvim",
  formatters_by_ft = {
    cpp = { "clang_format" },
    go = { "gopls" },
  },
  formatters = {
    clang_format = {
      prepend_args = { '-style="{IndentWidth: 4}"' },
    },
    gopls = {
      prepend_args = { '-style="{IndentWidth: 4}"' },
    },
  },
}
