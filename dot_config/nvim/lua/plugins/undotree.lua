vim.keymap.set("n", "<leader>u", function()
  vim.cmd("UndotreeToggle")
  vim.cmd("UndotreeFocus")
end, { desc = "toggle undo tree" })
