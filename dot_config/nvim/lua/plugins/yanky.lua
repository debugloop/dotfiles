require("yanky").setup({})
vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
vim.keymap.set({ "n", "x" }, "gp", "<Plug>(YankyGPutBefore)")
vim.keymap.set({ "n", "x" }, "gP", "<Plug>(YankyGPutAfter)")
vim.keymap.set("n", "<c-n>", "<Plug>(YankyCycleForward)")
vim.keymap.set("n", "<c-p>", "<Plug>(YankyCycleBackward)")
vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
  group = vim.api.nvim_create_augroup("YankyHighlight", {}),
  callback = function()
    vim.api.nvim_set_hl(0, "YankyPut", { link = "IncSearch" })
    vim.api.nvim_set_hl(0, "YankyYanked", { link = "IncSearch" })
  end,
})
