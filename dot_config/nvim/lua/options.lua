vim.cmd("syntax off") -- let treesitter handle things

-- general behavior
vim.opt.clipboard = "unnamedplus" -- sync yank with system clipboard
vim.opt.swapfile = false -- disable swap files
vim.opt.undofile = true -- enable persistent undo
vim.opt.undodir = "/home/danieln/.undo" -- set undo location
vim.opt.backup = true -- enable backup files
vim.opt.backupdir = "/home/danieln/.backup" -- set backup location
vim.opt.title = true
vim.opt.titlestring = [[vim %{substitute(getcwd(), '/home/danieln', '~', 0)}]]
vim.opt.jumpoptions = "stack"

vim.api.nvim_create_autocmd("BufRead,BufNewFile", { -- disable undofile and backup in gopass
  group = vim.api.nvim_create_augroup("on_read_dev", {}),
  pattern = "/dev/*",
  callback = function()
    vim.opt.undofile = false
    vim.opt.backup = false
  end,
})

-- editing
vim.opt.foldlevel = 999 -- no folding unless I close one myself
vim.opt.foldmethod = "expr" -- use below expression for folding
vim.opt.foldexpr = "nvim_treesitter#foldexpr()" -- get that folding expression from treesitter
vim.opt.spell = true -- spellcheck comments
vim.opt.spelllang = "en,de" -- spellcheck comments

-- finding stuff
vim.opt.gdefault = true -- show multiple matches per line without specifying global
vim.opt.ignorecase = true -- search case-insensitive
vim.opt.smartcase = true -- search case-sensitive when capital letters are searched

-- visuals
vim.opt.termguicolors = true -- assume a modern terminal and use 24bit RGB
vim.opt.breakindent = true -- indent wrapped lines
vim.opt.wrap = false -- don't wrap by default
vim.opt.number = true -- enable line numbers
vim.opt.relativenumber = true -- enable relative line numbers
vim.opt.scrolloff = 5 -- always show this many lines of context at the edges
vim.opt.sidescrolloff = 42 -- always show this many columns of context at the edges
vim.opt.laststatus = 3 -- single status line for all windows
vim.opt.splitbelow = true -- open horizontal splits below the current window
vim.opt.splitright = true -- open vertical splits to the right of the current window

vim.opt.listchars = "eol:¬,tab:»·,trail:~,space:·" -- list these chars if enabled

vim.api.nvim_create_autocmd({ "InsertEnter" }, { -- only in insert mode
  group = vim.api.nvim_create_augroup("on_insert_enter", {}),
  pattern = "*",
  callback = function()
    vim.opt.cursorline = true -- show line highlight
    vim.opt.relativenumber = false -- show relative line numbers
    vim.g.miniindentscope_disable = true -- disable plugin drawn guides, if present
  end,
})

vim.api.nvim_create_autocmd({ "InsertLeave" }, { -- revert to this on return
  group = vim.api.nvim_create_augroup("on_insert_leave", {}),
  pattern = "*",
  callback = function()
    vim.opt.cursorline = false -- don't show line highlight
    vim.opt.relativenumber = true -- don't show relative line numbers
    vim.g.miniindentscope_disable = false -- reenable plugin drawn guides, if present
  end,
})

vim.api.nvim_create_autocmd("VimResized", { -- equalize windows on resize
  group = vim.api.nvim_create_augroup("on_resize", {}),
  callback = function()
    vim.cmd("wincmd =")
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", { -- flash yanked text
  -- fallback, not used as long as yanky is installed
  group = vim.api.nvim_create_augroup("on_yank", {}),
  callback = function()
    vim.highlight.on_yank({ timeout = 300 })
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, { -- special settings for thunderbird
  pattern = "external_editor_revived_*.eml",
  callback = function()
    vim.cmd(vim.api.nvim_replace_termcodes("normal /^$", true, true, true))
    vim.cmd("normal 2n")
    -- vim.cmd('startinsert')
  end,
})
