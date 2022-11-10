require("toggleterm").setup({
  size = function(term)
    if term.direction == "horizontal" then
      return 15
    elseif term.direction == "vertical" then
      return vim.o.columns * 0.4
    end
  end,
  shade_terminals = false,
  hide_numbers = false,
})
vim.keymap.set(
  { "n", "t" },
  "<c-cr>",
  "<cmd>exe v:count1 . 'ToggleTerm direction=horizontal'<cr>",
  { desc = "launch terminal" }
)
vim.keymap.set(
  { "n", "t" },
  "<c-s-cr>",
  "<cmd>exe v:count1 . 'ToggleTerm direction=vertical'<cr>",
  { desc = "launch terminal vertical" }
)
vim.api.nvim_create_autocmd("TermOpen", { -- special settings for terminal
  pattern = "*",
  callback = function()
    local opts = { buffer = 0 }
    vim.keymap.set("t", "<c-n>", [[<C-\><C-n>]], opts)
    vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
    vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
    vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
    vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
    vim.opt.relativenumber = false
  end,
})
