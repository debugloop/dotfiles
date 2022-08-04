-- general behavior
vim.opt.clipboard = 'unnamedplus'   -- sync yank with system clipboard
vim.opt.swapfile = false            -- disable swap files
vim.opt.undofile = true             -- enable persistent undo
vim.opt.undodir = '~/.undo'         -- set undo location
vim.opt.backup = true               -- enable backup files
vim.opt.backupdir = '~/.backup'     -- set backup location
vim.api.nvim_create_autocmd("BufRead,BufNewFile", {  -- disable undofile and backup in gopass
  group = vim.api.nvim_create_augroup('on_read_dev', {}),
  pattern = "/dev/*",
  callback = function()
    vim.opt.backup = false
    vim.opt.undofile = false
  end,
})

-- editing
vim.opt.foldenable = false  -- no folding unless I close one myself
vim.opt.foldmethod = "expr"  -- use below expression for folding
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"  -- get that folding expression from treesitter

-- finding stuff
if vim.fn.executable("rg") == 1 then
  vim.opt.grepprg = "rg --vimgrep --smart-case --hidden"
  vim.opt.grepformat = "%f:%l:%c:%m"
end

vim.opt.gdefault = true  -- show multiple matches per line without specifying global
vim.opt.ignorecase = true  -- search case-insensitive
vim.opt.smartcase = true  -- search case-sensitive when capital letters are searched

-- visuals
vim.opt.termguicolors = true    -- assume a modern terminal and use 24bit RGB
vim.opt.breakindent = true      -- indent wrapped lines
vim.opt.number = true           -- enable line numbers
vim.opt.relativenumber = true   -- enable relative line numbers as well
vim.opt.scrolloff = 8           -- always show this many lines of context at the edges
vim.opt.sidescrolloff = 5       -- always show this many columns of context at the edges
vim.opt.laststatus = 3          -- single status line for all windows
vim.opt.cmdheight = 0           -- gain an extra line
vim.opt.splitbelow = true       -- open horizontal splits below the current window
vim.opt.splitright = true       -- open vertical splits to the right of the current window
vim.opt.cursorline = true       -- enable line highlight in any case

vim.api.nvim_create_autocmd({"WinLeave", "InsertEnter"}, {  -- only in insert mode and unfocused window
  group = vim.api.nvim_create_augroup('on_insert_enter', {}),
  pattern = "*",
  callback = function()
    vim.opt.cursorcolumn = true
    vim.opt.listchars = "eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:·"
    vim.opt.list = true
  end,
})

vim.api.nvim_create_autocmd({"WinEnter", "InsertLeave"}, {  -- revert to this on return
  group = vim.api.nvim_create_augroup('on_insert_leave', {}),
  pattern = "*",
  callback = function()
    vim.opt.cursorcolumn = false
    vim.opt.list = false
  end,
})

vim.api.nvim_create_autocmd("VimResized", {  -- equalize windows on resize
  group = vim.api.nvim_create_augroup('on_resize', {}),
  callback = function()
    vim.cmd("wincmd =")
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {  -- flash yanked text
  group = vim.api.nvim_create_augroup('on_yank', {}),
  callback = function() vim.highlight.on_yank({timeout = 300, on_visual = false}) end,
})
