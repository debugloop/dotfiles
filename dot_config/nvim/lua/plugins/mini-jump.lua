require("mini.jump").setup()

-- vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
--   group = vim.api.nvim_create_augroup("MinijumpHighlight", {}),
--   callback = function()
vim.api.nvim_set_hl(0, "MiniJump", { reverse = true })
--   end,
-- })
