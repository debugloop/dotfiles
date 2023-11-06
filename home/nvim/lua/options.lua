-- general behavior
vim.opt.clipboard = "unnamedplus" -- sync yank with system clipboard
vim.opt.termguicolors = true -- assume a modern terminal and use 24bit RGB
vim.opt.shada:append({ "%" }) -- reopen buffers if no args
vim.opt.shortmess:append({ W = true, I = true, c = true }) -- suppress some messages
vim.opt.updatetime = 500 -- faster cursor hold

-- tabs and spaces
vim.opt.shiftwidth = 0 -- look at tabstop, no sense in two settings
vim.opt.tabstop = 4 -- sane default for most things
vim.opt.expandtab = true -- use spaces instead of tabs

-- backups
vim.opt.backup = true -- enable backup files
vim.opt.backupdir = vim.fn.expand("~/.backup") -- set backup location
vim.opt.backupext = ".bak" -- disable suffix, we're in a backup dir
vim.opt.swapfile = false -- disable swap files
vim.opt.undodir = vim.fn.expand("~/.undo") -- set undo location
vim.opt.undofile = true -- enable persistent undo

-- window title
vim.opt.title = true -- use custom title
vim.opt.titlestring = [[vim %{substitute(getcwd(), '/home/danieln', '~', 0)}]] -- show cwd only

-- editing
vim.opt.foldenable = false -- no folding unless I close one myself
vim.opt.foldmethod = "indent" -- use indent for folding
vim.opt.jumpoptions = "stack" -- discard jumps when diverging from an earlier position
vim.opt.spelloptions = "camel,noplainbuffer" -- set some spell options for when I enable
vim.opt.textwidth = 120 -- text width, format comments to this

-- finding stuff
vim.opt.gdefault = true -- show multiple matches per line without specifying global
vim.opt.grepformat = "%f:%l:%c:%m" -- grep result format
vim.opt.grepprg = "rg --vimgrep" -- use fast grep
vim.opt.ignorecase = true -- search case-insensitive
vim.opt.smartcase = true -- search case-sensitive when capital letters are searched

-- bars
vim.opt.cmdheight = 0 -- more space on the bottom
vim.opt.laststatus = 0 -- no builtin statusline
vim.opt.showmode = false -- no mode show
vim.opt.signcolumn = "yes" -- always show signcolumn

-- virtual text
vim.opt.breakindent = true -- indent wrapped lines
vim.opt.listchars = "eol:¬,tab:»·,trail:~,space:·" -- list these chars if enabled
vim.opt.showbreak = "↪" -- virtual text for wrapped lines

-- lines
vim.opt.cursorline = true -- show line highlight
vim.opt.number = true -- enable line numbers
vim.opt.relativenumber = true -- enable relative line numbers

-- view
vim.opt.scrolloff = 16 -- always show this many lines of context at the edges
vim.opt.sidescrolloff = 20 -- always show this many columns of context at the edges

-- splits
vim.opt.splitbelow = true -- open horizontal splits below the current window
vim.opt.splitright = true -- open vertical splits to the right of the current window

-- diff
vim.opt.diffopt:append({ "linematch:60" }) -- better diff algorithm
vim.opt.fillchars:append({ diff = "╱" }) -- blank indicator

-- other
vim.g.markdown_recommended_style = 0 -- this makes markdown indent ok

-- display help in a vertical split
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("vertical_help", { clear = true }),
  pattern = { "*.txt" },
  callback = function()
    if vim.o.filetype == "help" then
      vim.cmd.wincmd("L")
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("on_markdown", { clear = true }),
  pattern = { "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.conceallevel = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("on_gitcommit", { clear = true }),
  pattern = { "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    vim.opt_local.textwidth = 72
    vim.opt_local.colorcolumn = "72"
  end,
})

-- auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = vim.api.nvim_create_augroup("auto_create_dir", { clear = true }),
  callback = function(event)
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- close some buffers with q only
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("close_with_q", { clear = true }),
  pattern = {
    "help",
    "dap-float",
    "dap-preview",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "startuptime",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>q<cr>", { buffer = event.buf, silent = true })
  end,
})

-- start with a fresh jumplist
vim.api.nvim_create_autocmd({ "VimEnter" }, {
  group = vim.api.nvim_create_augroup("on_startup", { clear = true }),
  pattern = "*",
  callback = function()
    vim.cmd("clearjumps")
  end,
})

-- do on entering insert mode
vim.api.nvim_create_autocmd({ "InsertEnter" }, {
  group = vim.api.nvim_create_augroup("on_insert_enter", { clear = true }),
  pattern = "*",
  callback = function()
    vim.opt.relativenumber = false -- don't show relative line numbers
    vim.g.miniindentscope_disable = true -- disable plugin drawn guides, if present
  end,
})

-- do on entering normal mode
vim.api.nvim_create_autocmd({ "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("on_insert_leave", { clear = true }),
  pattern = "*",
  callback = function(event)
    if vim.bo[event.buf].ft == "TelescopePrompt" then
      vim.opt.relativenumber = false
      return
    end
    vim.opt.relativenumber = true -- show relative line numbers
    vim.g.miniindentscope_disable = false -- re-enable plugin drawn guides, if present
  end,
})

-- equalize windows on resize
vim.api.nvim_create_autocmd("VimResized", {
  group = vim.api.nvim_create_augroup("balance_splits", { clear = true }),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- flash yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ timeout = 300 })
  end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("goto_last_location", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- tag initial buffers as persistent
vim.api.nvim_create_autocmd({ "VimEnter" }, {
  group = vim.api.nvim_create_augroup("persist_on_vim_open", { clear = true }),
  callback = function()
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      vim.fn.setbufvar(bufnr, "bufpersist", 1)
    end
  end,
})

-- tag edited buffers as persistent
vim.api.nvim_create_autocmd({ "BufRead" }, {
  group = vim.api.nvim_create_augroup("autocmd_on_buf_enter", { clear = true }),
  pattern = { "*" },
  callback = function()
    vim.api.nvim_create_autocmd({ "InsertEnter", "BufModifiedSet" }, {
      buffer = 0,
      once = true,
      callback = function()
        vim.fn.setbufvar(vim.api.nvim_get_current_buf(), "bufpersist", 1)
      end,
    })
  end,
})

-- terminals
vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("on_term_open", { clear = true }),
  pattern = "*",
  callback = function(event)
    vim.keymap.set("t", "<c-n>", [[<C-\><C-n>]], { buffer = event.buf })
    vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], { buffer = event.buf })
    vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], { buffer = event.buf })
    vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], { buffer = event.buf })
    vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], { buffer = event.buf })
    vim.opt.relativenumber = false
  end,
})
vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter", "TermOpen" }, {
  group = vim.api.nvim_create_augroup("on_term_enter", { clear = true }),
  callback = function(args)
    if vim.startswith(vim.api.nvim_buf_get_name(args.buf), "term://") then
      vim.cmd("startinsert")
    end
  end,
})
