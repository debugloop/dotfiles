vim.g.mapleader = ' '

-- movement between buffers
vim.keymap.set('n', '<Tab>', '<cmd>bn<cr>')
vim.keymap.set('n', '<S-Tab>', '<cmd>bp<cr>')
vim.keymap.set('n', '<leader><Tab>', '<cmd>bd<cr>')

-- smart beginning and end of line
vim.keymap.set('n', 'H', function()
  _, line, col, _ = unpack(vim.fn.getpos("."))
  vim.cmd("normal! ^")
  if col == vim.fn.getpos(".")[3] then
    vim.cmd("normal! 0")
  end
end)
vim.keymap.set({'o', 'v'}, 'H', '^')
vim.keymap.set({'n', 'o', 'v'}, 'L', '$')

-- quickfix window navigation
vim.keymap.set('n', '<C-j>', '<cmd>cnext<cr>')
vim.keymap.set('n', '<C-k>', '<cmd>cprevious<cr>')
vim.keymap.set('n', '<C-n>', '<cmd>cnext<cr>')
vim.keymap.set('n', '<C-m>', '<cmd>cprevious<cr>')
vim.keymap.set('n', '<C-q>', '<cmd>cclose<cr>')

-- clear highlighting
vim.keymap.set('n', '<C-c>', '<cmd>nohl<cr>')

-- jump back to last position
vim.keymap.set('n', '<bs>', "''")

-- navigate between visual lines, even if they're wrapped
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')
vim.keymap.set('n', 'gj', 'j')
vim.keymap.set('n', 'gk', 'k')

-- move visual blocks
vim.keymap.set('v', 'J', ":m '>+1<cr>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<cr>gv=gv")

-- stay in visual after indent
vim.keymap.set('v', '<', "<gv")
vim.keymap.set('v', '>', ">gv")

-- fix Y map
vim.keymap.set('n', 'Y', 'y$')

-- jump to buffer
vim.keymap.set('n', '<leader>1', '<cmd>1b<cr>', { desc = "go to buffer 1" })
vim.keymap.set('n', '<leader>2', '<cmd>2b<cr>', { desc = "go to buffer 2" })
vim.keymap.set('n', '<leader>3', '<cmd>3b<cr>', { desc = "go to buffer 3" })
vim.keymap.set('n', '<leader>4', '<cmd>4b<cr>', { desc = "go to buffer 4" })
vim.keymap.set('n', '<leader>5', '<cmd>5b<cr>', { desc = "go to buffer 5" })
vim.keymap.set('n', '<leader>6', '<cmd>6b<cr>', { desc = "go to buffer 6" })
vim.keymap.set('n', '<leader>7', '<cmd>7b<cr>', { desc = "go to buffer 7" })
vim.keymap.set('n', '<leader>8', '<cmd>8b<cr>', { desc = "go to buffer 8" })
vim.keymap.set('n', '<leader>9', '<cmd>9b<cr>', { desc = "go to buffer 9" })
vim.keymap.set('n', '<leader>0', '<cmd>10b<cr>', { desc = "go to buffer 10" })

-- sorting of lines
vim.keymap.set('v', '<leader>s', '<cmd>!sort<cr>')

-- banish ex mode
vim.keymap.set('n', 'gQ', '<nop>')

-- no yank delete
vim.keymap.set('n', 'X', '"_d')
vim.keymap.set('n', 'XX', '"_dd')
