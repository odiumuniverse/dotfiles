-- In the Claude terminal <C-h/j/k/l> belong to herdr-smart-nav (nvim window -> herdr pane -> tab):
-- LazyVim's snacks terminal keys would only move between nvim windows there.
return {
  "odiumuniverse/claudecode.nvim",
  opts = {
    terminal = {
      snacks_win_opts = {
        keys = { nav_h = false, nav_j = false, nav_k = false, nav_l = false },
      },
    },
  },
}
