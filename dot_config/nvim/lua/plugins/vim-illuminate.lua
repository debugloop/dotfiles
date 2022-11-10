require("illuminate").configure({
  providers = {
    "treesitter",
    "regex",
  },
  modes_allowlist = { "n", "i" },
  filetypes_denylist = {
    "terminal",
  },
})

vim.keymap.set("n", "<leader>i", require("illuminate").toggle, { desc = "illuminate: toggle" })
vim.keymap.set("n", "]r", function()
  for _ = 1, vim.v.count1 do
    require("illuminate").goto_next_reference()
  end
end, { desc = "illuminate: jump to next reference" })
vim.keymap.set("n", "[r", function()
  for _ = 1, vim.v.count1 do
    require("illuminate").goto_prev_reference()
  end
end, { desc = "illuminate: jump to previous reference" })
vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
  group = vim.api.nvim_create_augroup("IlluminateHighlight", {}),
  callback = function()
    vim.api.nvim_set_hl(0, "IlluminatedWordRead", { link = "Visual" })
    vim.api.nvim_set_hl(0, "IlluminatedWordText", { link = "Visual" })
    vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { fg = "orange" })
  end,
})
