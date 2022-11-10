require("mini.trailspace").setup({}) -- highlight and remove trailing spaces
vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
  group = vim.api.nvim_create_augroup("MinitrailspaceHighlight", {}),
  callback = function()
    vim.api.nvim_set_hl(0, "MiniTrailspace", { undercurl = true, sp = "red" })
  end,
})
vim.keymap.set("n", "<leader>w", require("mini.trailspace").trim, { desc = "trim trailing whitespace" })
