-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Spell check in British English and Italian: a word is accepted if it is
-- valid in either (LazyVim enables spell for prose filetypes). The novel
-- folder is British English only (lua/novel). Override one file with a
-- modeline in its last five lines, e.g. <!-- vim: set spelllang=it: -->
vim.opt.spelllang = { "en_gb", "it" }
