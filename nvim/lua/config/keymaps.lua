-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- VSCode style keymaps (for terminal with Cmd key support)
local map = vim.keymap.set

-- Cmd+P: File search (like VSCode's Quick Open)
map("n", "<D-p>", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
map("i", "<D-p>", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })

-- Cmd+Shift+F: Global text search (like VSCode's Search)
map("n", "<D-S-f>", "<cmd>Telescope live_grep<cr>", { desc = "Search in Files" })
map("i", "<D-S-f>", "<cmd>Telescope live_grep<cr>", { desc = "Search in Files" })
