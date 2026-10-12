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

-- <C-h/j/k/l> are owned by herdr-smart-nav (nvim window -> herdr pane -> tab -> space).
-- Do NOT map them here: this file loads on VeryLazy and would override HerdrNavigate*.
