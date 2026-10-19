-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
-- Open a completely new desktop terminal window at the current file's directory
vim.keymap.set("n", "<leader>to", function()
  local current_dir = vim.fn.expand("%:p:h")
  -- For Alacritty:
  vim.fn.jobstart({ "alacritty", "--working-directory", current_dir }, { detach = true })
  -- OR if you use Kitty:
  -- vim.fn.jobstart({ "kitty", "--directory", current_dir }, { detach = true })
end, { desc = "Open external terminal here" })
