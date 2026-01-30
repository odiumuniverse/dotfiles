return {
  {
    "folke/snacks.nvim",
    opts = {
      explorer = { enabled = false },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      options = {
        use_as_default_explorer = true,
      },
      filesystem = {
        filtered_items = {
          visible = true,
          show_hidden_count = false,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = {
            ".git",
            ".DS_Store",
            ".idea",
            -- 'thumbs.db',
          },
          never_show = { ".git" },
        },
      },
    },
  },
}
