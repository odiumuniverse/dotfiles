return {
  "monkoose/neocodeium",
  event = "VeryLazy",
  opts = { show_label = false },
  config = function(_, opts)
    local neocodeium = require("neocodeium")
    neocodeium.setup(opts)

    -- <Tab> is owned by blink.cmp: snippet_forward -> ai_nes -> ai_accept -> fallback
    LazyVim.cmp.actions.ai_accept = function()
      if neocodeium.visible() then
        LazyVim.create_undo()
        neocodeium.accept()
        return true
      end
    end

    vim.keymap.set("i", "<M-]>", function() neocodeium.cycle(1) end)
    vim.keymap.set("i", "<M-[>", function() neocodeium.cycle(-1) end)
  end,
}
