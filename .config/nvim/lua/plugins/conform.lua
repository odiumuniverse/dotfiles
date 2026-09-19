return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        -- prettierd — демон, стартует один раз и держится в памяти;
        -- prettier — запасной вариант, если демон не поднялся.
        markdown = { "prettierd", "prettier", stop_after_first = true },
        ["markdown.mdx"] = { "prettierd", "prettier", stop_after_first = true },
      },
    },
  },
  -- prettierd ставится автоматически на чистой машине
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "prettierd" } },
  },
}
