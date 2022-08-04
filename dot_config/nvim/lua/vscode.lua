-- do not load any plugins by default
vim.opt.loadplugins = false

-- echasnovski/mini.nvim
vim.cmd([[packadd mini.nvim]])
require('mini.ai').setup()  -- better text objects
require('mini.comment').setup()  -- commenting
require('mini.jump').setup()  -- better f and t mappings
vim.api.nvim_set_hl(0, 'MiniJump', { reverse = true })
require('mini.jump2d').setup({ mappings = { start_jumping = 'S' } })  -- advanced jump on S
vim.api.nvim_set_hl(0, 'MiniJump2dSpot', { reverse = true })
require('mini.pairs').setup()  -- autocomplete pairs
require('mini.surround').setup({ search_method = 'cover_or_next' })  -- change surroundings

vim.api.nvim_exec([[
nnoremap zM :call VSCodeNotify('editor.foldAll')<CR>
nnoremap zR :call VSCodeNotify('editor.unfoldAll')<CR>
nnoremap zc :call VSCodeNotify('editor.fold')<CR>
nnoremap zC :call VSCodeNotify('editor.foldRecursively')<CR>
nnoremap zo :call VSCodeNotify('editor.unfold')<CR>
nnoremap zO :call VSCodeNotify('editor.unfoldRecursively')<CR>
nnoremap za :call VSCodeNotify('editor.toggleFold')<CR>
]], false)
