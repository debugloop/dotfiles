require("mini.indentscope").setup({
  draw = {
    animation = require("mini.indentscope").gen_animation("none"),
  },
  symbol = "ˑּ",
  options = {
    try_as_border = true,
  },
})
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("indentscope_python", {}),
  pattern = "python",
  callback = function()
    require("mini.indentscope").config.options.border = "top"
  end,
})
