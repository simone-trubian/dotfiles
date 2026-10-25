-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- F1 sits next to Esc and gets hit instead of it. Do nothing, so the miss is
-- noticed, rather than open :help (help is Space s h, or :h <topic>).
vim.keymap.set({ "n", "v", "o", "i", "c", "t" }, "<F1>", "<Nop>", { desc = "Nothing (F1 is not help)" })
