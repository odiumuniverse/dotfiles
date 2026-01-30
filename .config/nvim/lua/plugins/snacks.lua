local function set_explorer_hl()
  vim.api.nvim_set_hl(0, "SnacksExplorerNormal", { bg = "none" })
  vim.api.nvim_set_hl(0, "SnacksExplorerBorder", { bg = "none" })
  vim.api.nvim_set_hl(0, "SnacksExplorerTitle", { bg = "none" })
end

return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          layout = {
            layout = {
              width = 30,
              min_width = 30,
            },
          },
          win = {
            list = {
              wo = {
                winhighlight = "Normal:SnacksExplorerNormal,NormalFloat:SnacksExplorerNormal",
              },
            },
            input = {
              wo = {
                winhighlight = "Normal:SnacksExplorerNormal,NormalFloat:SnacksExplorerNormal,FloatBorder:SnacksExplorerBorder,FloatTitle:SnacksExplorerTitle",
              },
            },
          },
        },
      },
    },
  },
  init = function()
    set_explorer_hl()
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      callback = set_explorer_hl,
    })
  end,
}
