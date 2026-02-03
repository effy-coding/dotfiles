-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- VSCode style keymaps (for terminal with Cmd key support)
local map = vim.keymap.set

-- Cmd+P: File search (like VSCode's Quick Open)
-- Ghostty sends Ctrl+] p (\x1dp) for Cmd+P via tmux
map("n", "<D-p>", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
map("i", "<D-p>", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
map("n", "<C-]>p", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
map("i", "<C-]>p", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })

-- Cmd+Shift+F: Global text search (like VSCode's Search)
-- Ghostty sends Ctrl+] f (\x1df) for Cmd+Shift+F via tmux
map("n", "<D-S-f>", "<cmd>Telescope live_grep<cr>", { desc = "Search in Files" })
map("i", "<D-S-f>", "<cmd>Telescope live_grep<cr>", { desc = "Search in Files" })
map("n", "<C-]>f", "<cmd>Telescope live_grep<cr>", { desc = "Search in Files" })
map("i", "<C-]>f", "<cmd>Telescope live_grep<cr>", { desc = "Search in Files" })
