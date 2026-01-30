-- Treesitter configuration with only needed languages
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        -- Core languages
        "lua",
        "luadoc",
        "vim",
        "vimdoc",
        "query", -- treesitter query language

        -- Go development
        "go",
        "gomod",
        "gosum",
        "gowork",

        -- Web development
        "html",
        "css",
        "javascript",
        "typescript",
        "tsx",

        -- Data formats
        "json",
        "yaml",
        "toml",

        -- Documentation
        "markdown",
        "markdown_inline",

        -- Shell
        "bash",
        "zsh",

        -- Infrastructure (Terraform, etc.)
        "hcl",

        -- Database
        "sql",

        -- Git
        "gitcommit",
        "gitignore",
        "diff",
      },
      -- Don't auto-install all parsers
      auto_install = false,
    },
  },
}
