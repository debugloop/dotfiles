-- autopair on newline
vim.keymap.set("i", "do<cr>", "do<cr>end<esc>O", { noremap = true })
vim.keymap.set("i", "then<cr>", "then<cr>end<esc>O", { noremap = true })

-- indent
vim.opt.tabstop = 2
vim.opt.expandtab = true
