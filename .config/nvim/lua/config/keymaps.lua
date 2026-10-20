-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Go test
map("n", "<leader>rta", "<cmd>GoTest<cr>", { desc = "Test all" })
map("n", "<leader>rtp", "<cmd>GoTestPkg<cr>", { desc = "Test package" })
map("n", "<leader>rc", "<cmd>GoCoverage<cr>", { desc = "Test coverage" })
map("n", "<leader>rg", "<cmd>GoAddTest<cr>", { desc = "Generate test for function" })
map("n", "<leader>fs", "<cmd>GoFillStruct<cr>", { desc = "Fill Go struct" })

-- Obsidian
map("n", "<leader>o", "<cmd>Obsidian<cr>", { desc = "Obsidian" })

-- Go Tags for structs
map("n", "<leader>ta", "<cmd>GoAddTag<cr>", { desc = "Add tags" })
map("n", "<leader>tr", "<cmd>GoRmTag<cr>", { desc = "Remove tags" })
map("n", "<leader>tc", "<cmd>GoClearTag<cr>", { desc = "Clear tags" })

-- Go to Alternative file testfile/file
map("n", "<leader>m", "<cmd>GoAlt!<cr>", { desc = "Alternative file" })

-- Go Debug
map("n", "<leader>dS", "<cmd>GoDebug -t<cr>", { desc = "Run debug for test" })
map("n", "<leader>dR", "<cmd>GoDebug -R<cr>", { desc = "Restart debug for test" })
map("n", "<leader>dE", "<cmd>GoDbgStop<cr>", { desc = "Stop debug" })

map({ "i", "s" }, "jk", "<cmd>noh<cr><esc>", { desc = "Escape and Clear search" })

-- Lazygit in the repo of the file you work on. nvim started above several repos (~/topscan) has
-- none of its own: from a terminal (Claude) the last file you were in counts, from neo-tree the node.
local last_file = nil
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("user_last_file", { clear = true }),
  callback = function(ev)
    local name = vim.api.nvim_buf_get_name(ev.buf)
    if vim.bo[ev.buf].buftype == "" and name ~= "" then
      last_file = name
    end
  end,
})

local function work_path()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].filetype == "neo-tree" then
    local ok, node = pcall(function()
      return require("neo-tree.sources.manager").get_state("filesystem").tree:get_node()
    end)
    if ok and node and node.path then
      return node.path
    end
  end
  if vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
    return vim.api.nvim_buf_get_name(buf)
  end
  return last_file
end

map("n", "<leader>gg", function()
  local path = work_path()
  local dir = path and (vim.fn.isdirectory(path) == 1 and path or vim.fs.dirname(path)) or vim.uv.cwd()
  local git = vim.fs.find(".git", { path = dir, upward = true })[1]
  Snacks.lazygit({ cwd = git and vim.fs.dirname(git) or vim.uv.cwd() })
end, { desc = "Lazygit (repo of the current file)" })

-- <C-h/j/k/l> are owned by herdr-smart-nav (nvim window -> herdr pane -> tab -> space).
-- Do NOT map them here: this file loads on VeryLazy and would override HerdrNavigate*.
