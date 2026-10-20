return {
  "nvim-neo-tree/neo-tree.nvim",
  -- <leader>e shows the directory nvim was started in (~/topscan: every repo in it); LazyVim's
  -- default narrows the tree to the repo of the current file, which is now <leader>E.
  keys = {
    {
      "<leader>e",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
      end,
      desc = "Explorer NeoTree (cwd)",
    },
    {
      "<leader>E",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() })
      end,
      desc = "Explorer NeoTree (Root Dir)",
    },
  },
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,
        show_hidden_count = false,
        hide_dotfiles = false,
        hide_gitignored = true,
        hide_by_name = {
          ".DS_Store",
          ".idea",
        },
        never_show = { ".git" },
      },
    },
  },
}
