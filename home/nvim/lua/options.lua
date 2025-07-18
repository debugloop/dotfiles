-- general behavior
vim.opt.updatetime = 500 -- faster CursorHold
vim.opt.mouse = "" -- no mouse
vim.opt.jumpoptions = "stack,view" -- discard jumps when diverging from an earlier position
vim.opt.spelloptions = "camel,noplainbuffer" -- set some spell options for when I enable
vim.opt.spellsuggest = "best,10" -- limit suggestions
vim.opt.clipboard = "unnamedplus"
vim.opt.formatoptions = "tcr/qnj"
vim.opt.nrformats = "unsigned,bin,hex"

-- indent and wrap defaults
vim.opt.shiftwidth = 0 -- look at tabstop, no sense in two settings
vim.opt.tabstop = 4 -- sane default for most things
vim.opt.expandtab = true -- use spaces instead of tabs
vim.opt.textwidth = 120 -- text width, format comments to this
vim.opt.linebreak = true -- prefer wrap at spaces

-- file safety
vim.opt.backup = true -- enable backup files
vim.opt.backupdir = vim.fn.expand("~/.backup") -- set backup location
vim.opt.backupext = ".bak" -- use bak suffix
vim.opt.undodir = vim.fn.expand("~/.undo") -- set undo location
vim.opt.undofile = true -- enable persistent undo
vim.opt.swapfile = false -- disable swap files

-- window title
vim.opt.title = true -- use custom title
vim.opt.titlestring = [[vim %{substitute(getcwd(), '/home/danieln', '~', 0)}]] -- show cwd only

-- folds
vim.opt.foldenable = true
vim.opt.foldlevel = 99
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = ""
vim.opt.foldcolumn = "0"

-- finding stuff
vim.opt.gdefault = true -- show multiple matches per line without specifying global
vim.opt.ignorecase = true -- search case-insensitive
vim.opt.smartcase = true -- search case-sensitive when capital letters are searched

-- ui
vim.opt.cmdheight = 0 -- more space on the bottom
vim.opt.laststatus = 3 -- global statusline
vim.opt.showmode = false -- less data in invisible cmd area

-- virtual text
vim.opt.listchars = "eol:¬,tab:»·,trail:~,space:·" -- list these chars if enabled

-- lines
vim.opt.cursorline = true -- show line highlight
vim.opt.number = true -- enable line numbers
vim.opt.relativenumber = true -- enable relative line numbers

-- view
vim.opt.scrolloff = 8 -- always show this many lines of context at the edges
vim.opt.sidescrolloff = 16 -- always show this many columns of context at the edges

-- splits
vim.opt.splitbelow = true -- open horizontal splits below the current window
vim.opt.splitright = true -- open vertical splits to the right of the current window

-- diff
vim.opt.diffopt = "internal,filler,closeoff,indent-heuristic,linematch:60,algorithm:histogram" -- better diff algorithm
vim.opt.fillchars:append({ diff = "╱" }) -- blank indicator

-- detect filetypes
vim.filetype.add({
  pattern = {
    [".*deploy.*%.yaml"] = "gotmpl",
    [".*deploy.*%.yml"] = "gotmpl",
  },
})

-- change diagnostic display
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
  },
  virtual_text = {
    format = function(d)
      return d.source .. (d.code or "")
    end,
  },
  virtual_lines = {
    format = function(d)
      return d.message
    end,
    current_line = true,
  },
  severity_sort = true,
})
