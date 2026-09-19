local ROOT = "/Users/universe/my/herdr-smart-nav"
return {
  dir = ROOT,
  name = "herdr-smart-nav",
  config = function()
    local load = function()
      dofile(ROOT .. "/editor/nvim.lua")
    end
    load()
    vim.api.nvim_create_autocmd("User", {
      group = vim.api.nvim_create_augroup("HerdrSmartNav", { clear = true }),
      pattern = "VeryLazy",
      callback = load,
    })
  end,
}
