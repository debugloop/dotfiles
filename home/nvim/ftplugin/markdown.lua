-- autopair on newline
vim.keymap.set("i", "```<cr>", "```<cr>```<esc>O", { noremap = true })

-- format
vim.opt.textwidth = 100
vim.opt.wrap = true
vim.opt.conceallevel = 2
