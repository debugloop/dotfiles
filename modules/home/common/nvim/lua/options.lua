-- general behavior
vim.o.updatetime = 500 -- faster CursorHold
vim.o.mouse = "" -- no mouse
vim.o.jumpoptions = "stack,view" -- discard jumps when diverging from an earlier position
vim.o.spelloptions = "camel,noplainbuffer" -- set some spell options for when I enable
vim.o.spellsuggest = "best,10" -- limit suggestions
vim.o.formatoptions = "tcrqnj"
vim.o.shortmess = "CFOSWaco"
vim.o.nrformats = "unsigned,bin,hex"
vim.o.clipboard = "unnamedplus"
vim.o.switchbuf = "usetab" -- use already opened buffers when switching
vim.o.iskeyword = "@,48-57,_,192-255,-" -- add to word textobject
vim.o.formatlistpat = [[^\s*[0-9\-\+\*]\+[\.\)]*\s\+]] -- pattern for a start of numbered list

-- indent and wrap defaults
vim.o.shiftwidth = 0 -- look at tabstop, no sense in two settings
vim.o.tabstop = 4 -- sane default for most things
vim.o.expandtab = true -- use spaces instead of tabs
vim.o.textwidth = 120 -- text width, format comments to this
vim.o.linebreak = true -- prefer wrap at spaces
vim.o.breakindent = true -- indent wrapped lines to match line start
vim.o.breakindentopt = "list:-1" -- add padding for lists (if 'wrap' is set)

-- file safety
vim.o.backup = true -- enable backup files
vim.o.backupdir = vim.fn.expand("~/.backup") -- set backup location
vim.o.backupext = ".bak" -- use bak suffix
vim.o.undodir = vim.fn.expand("~/.undo") -- set undo location
vim.o.undofile = true -- enable persistent undo
vim.o.swapfile = false -- disable swap files

-- window title
vim.o.title = true -- use custom title
vim.o.titlestring = [[vim %{substitute(getcwd(), '/home/danieln', '~', 0)}]] -- show cwd only

-- folds
vim.o.foldenable = true
vim.o.foldlevel = 99
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldtext = ""
vim.o.foldcolumn = "0"

-- finding stuff
vim.o.gdefault = true -- show multiple matches per line without specifying global
vim.o.ignorecase = true -- search case-insensitive
vim.o.smartcase = true -- search case-sensitive when capital letters are searched

-- ui
vim.o.cmdheight = 0 -- more space on the bottom
vim.o.laststatus = 3 -- global statusline
vim.o.showmode = false -- less data in invisible cmd area
vim.o.signcolumn = "yes" -- always show signcolumn (less flicker)

-- virtual text
vim.o.listchars = "eol:¬,tab:»·,trail:~,space:·" -- list these chars if enabled

-- lines
vim.o.cursorline = true -- show line highlight
vim.o.cursorlineopt = "screenline,number" -- show cursor line per screen line
vim.o.number = true -- enable line numbers
vim.o.relativenumber = true -- enable relative line numbers

-- view
vim.o.scrolloff = 8 -- always show this many lines of context at the edges
vim.o.sidescrolloff = 8 -- always show this many columns of context at the edges

-- splits
vim.o.splitbelow = true -- open horizontal splits below the current window
vim.o.splitright = true -- open vertical splits to the right of the current window
vim.o.splitkeep = "screen" -- reduce scroll during window split

-- diff
vim.o.diffopt = "internal,filler,closeoff,indent-heuristic,linematch:60,algorithm:histogram" -- better diff algorithm
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
