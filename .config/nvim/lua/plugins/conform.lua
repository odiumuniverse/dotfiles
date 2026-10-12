local golangci_config = { ".golangci.yml", ".golangci.yaml" }

return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        -- Проект с .golangci.yml форматируется так же, как `make fmt` (topscan — gci, home — gofmt);
        -- goimports+gofumpt — только в проектах без .golangci.yml.
        go = function(bufnr)
          if vim.fs.root(bufnr, golangci_config) then
            return { "goimports", "golangci-lint" }
          end
          return { "goimports", "gofumpt" }
        end,
        -- prettierd — демон, стартует один раз и держится в памяти;
        -- prettier — запасной вариант, если демон не поднялся.
        markdown = { "prettierd", "prettier", stop_after_first = true },
        ["markdown.mdx"] = { "prettierd", "prettier", stop_after_first = true },
      },
      formatters = {
        -- golangci-lint ищет конфиг и go.mod от cwd, а не от файла
        ["golangci-lint"] = {
          cwd = function(_, ctx)
            return vim.fs.root(ctx.dirname, golangci_config)
          end,
          require_cwd = true,
        },
      },
    },
  },
  -- prettierd ставится автоматически на чистой машине
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "prettierd" } },
  },
}
