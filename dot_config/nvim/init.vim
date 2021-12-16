"####################################################################
" .vimrc
"####################################################################

"####################################################################
" install plugins {{{
"####################################################################

" automatic installation of plug on fresh deployments
if !filereadable(expand('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin()
" views
Plug 'mbbill/undotree' " <leader>u, defined below
Plug 'airblade/vim-gitgutter', { 'on':  'GitGutterToggle' } " <leader>g, defined below
Plug 'justinmk/vim-dirvish' " -, defined by plug

" visuals
Plug 'arcticicestudio/nord-vim'
Plug 'ap/vim-buftabline' " buffers as tabs

" editing
Plug 'tpope/vim-sleuth' " never bother with indents
Plug 'tpope/vim-commentary' " toggle comments according to ft (mapping: gc)
Plug 'tpope/vim-surround'
" Cheatsheet for surround:
"  cs + $old_surrounding + $new_surrounding = changes old to new, new waits for
"      xml tags, to use xml tags as $old, use 't'
"  ys adds/wraps
" Plug 'justinmk/vim-sneak' " s motion, z as operator (i.e. dzxy)
Plug 'ggandor/lightspeed.nvim'

" new neovim features
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" language support
Plug 'arp242/gopher.vim', {'for': 'go'} " modern vim-go, lsp friendly
" Plug 'sebdah/vim-delve', {'for': 'go'} " debug go
Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'
Plug 'theHamsta/nvim-dap-virtual-text'
Plug 'leoluz/nvim-dap-go', {'for': 'go'}
Plug 'ap/vim-css-color'
Plug 'pearofducks/ansible-vim', {'for': 'yaml.ansible'}
Plug 'dag/vim-fish', {'for': 'fish'}
Plug 'ledger/vim-ledger', {'for': 'ledger'}

call plug#end()

"" }}}

"####################################################################
" general settings {{{
"####################################################################
" filetype plugin and syntax
syntax on
set synmaxcol=512 " don't overdo it
filetype plugin indent on

" single settings
set hidden " change buffers without saving
set mouse=a " allow mouse usage
set foldmethod=marker " use manual folding
set scrolloff=16 " minimum lines to the screens end
set sidescrolloff=5 " minimum columns to the screens end
set noswapfile " 21. century, yay
set gdefault " substitution is global by default, specify g to reverse
set clipboard^=unnamedplus " use system clipboard
set completeopt=menu,menuone,noselect " better completion experience
inoremap <S-Tab> <C-x><C-o><C-n>

" open splits in nicer locations
set splitbelow
set splitright

" persistent undo and backup
set undofile
set undodir=~/.undo/
set backup
set backupdir=~/.backup/

" search
set ignorecase
set smartcase

" snappy timeouts
set notimeout
set nottimeout

"" }}}

"####################################################################
" visual style {{{
"####################################################################

" force nice colors in term
set termguicolors

" line and column highlights
set cursorline
set cursorcolumn
augroup cursorcolumn
  au!
  au WinLeave,InsertEnter * set nocursorcolumn
  au WinEnter,InsertLeave * set cursorcolumn
augroup END

" linenumbers
set number
set relativenumber

" show whitespace chars
set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:·
augroup list
  au!
  au WinLeave,InsertEnter * set list
  au WinEnter,InsertLeave * set nolist
augroup END

" in insert mode, don't vary beam color along with syntax highlight
set guicursor=i:ver25Cursor/lCursor

" highlight git merge markers
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'
"" }}}

"####################################################################
" general auto commands {{{
"####################################################################

" do not backup pass files
autocmd BufRead,BufNewFile /dev/shm* set nobackup
autocmd BufRead,BufNewFile /dev/shm* set noundofile
autocmd BufRead,BufNewFile /dev/shm* set noswapfile

" enforce ansible mode in playbook dir
au BufRead,BufNewFile ~/playbook/*.yml set filetype=yaml.ansible

" autoremove trailing whitespace
au BufRead,BufWrite * if ! &bin | silent! %s/\s\+$//ge | endif

" highlight yanked
au TextYankPost * lua vim.highlight.on_yank {higroup="IncSearch", timeout=300, on_visual=true}

" grow and shrink splits with the window
au VimResized * :wincmd =
"" }}}

"####################################################################
" keymaps {{{
"####################################################################

let mapleader = "\<Space>"

map q: :q

" smarter go to beginning of line
function! ToggleMovement(firstOp, thenOp)
  let pos = getpos('.')
  execute "normal! " . a:firstOp
  if pos == getpos('.')
    execute "normal! " . a:thenOp
  endif
endfunction
noremap <silent> H :call ToggleMovement('^', '0')<cr>
noremap L $

" jump to visual lines
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k

" move visual block
vnoremap J :m '>+1<cr>gv=gv
vnoremap K :m '<-2<cr>gv=gv

" stay in visual after indent
vnoremap < <gv
vnoremap > >gv

" highlight last inserted text
nnoremap gV `[v`]

" change Y from yy to y$
map Y y$

" switch buffers
nnoremap <silent><leader><Tab> :bd<cr>
nnoremap <silent><Tab> :bn<cr>
nnoremap <silent><S-Tab> :bp<cr>
if exists(':tnoremap')
  tnoremap <silent><Tab> :bn<cr>
  tnoremap <silent><S-Tab> :bp<cr>
  tnoremap <Esc> <C-\><C-n>
endif

" save with sudo
cmap w!! w !sudo tee %

" jump to buffer
"nnoremap <leader><leader> <C-^>
nnoremap <leader>1 :1b<cr>
nnoremap <leader>2 :2b<cr>
nnoremap <leader>3 :3b<cr>
nnoremap <leader>4 :4b<cr>
nnoremap <leader>5 :5b<cr>
nnoremap <leader>6 :6b<cr>
nnoremap <leader>7 :7b<cr>
nnoremap <leader>8 :8b<cr>
nnoremap <leader>9 :9b<cr>
nnoremap <leader>0 :10b<cr>

" sorting of lines
vnoremap <leader>s :!sort<cr>

" quickfix usability
map <C-n> :cnext<cr>
map <C-m> :cprevious<cr>
nnoremap <expr> <C-c> !empty(filter(tabpagebuflist(), 'getbufvar(v:val, "&buftype") is# "quickfix"')) ? ':cclose<cr>' : ':nohl<cr>:lua vim.lsp.buf.clear_references()<cr>'

" remove search hl (see qf mapping above)
" nnoremap <silent><C-c> :nohl<cr>

" banish ex mode
nnoremap Q <Nop>
nnoremap gQ <Nop>

"" }}}

"####################################################################
" status bar {{{
"####################################################################
set cmdheight=1
set laststatus=2
set showcmd
set noshowmode

function! StatuslineGit()
  let l:branchname = trim(system("git -C " . expand("%:h") . " branch --show-current 2>/dev/null"))
  return strlen(l:branchname) > 0?'  '.l:branchname.' ':''
endfunction

let g:currentmode={
    \ 'n'  : 'Normal',
    \ 'no' : 'Normal·Operator Pending',
    \ 'v'  : 'Visual',
    \ 'V'  : 'V·Line',
    \ "\<C-V>" : 'V·Block',
    \ 's'  : 'Select',
    \ 'S'  : 'S·Line',
    \ '^S' : 'S·Block',
    \ 'i'  : 'Insert',
    \ 'R'  : 'Replace',
    \ 'Rv' : 'V·Replace',
    \ 'c'  : 'Command',
    \ 'cv' : 'Vim Ex',
    \ 'ce' : 'Ex',
    \ 'r'  : 'Prompt',
    \ 'rm' : 'More',
    \ 'r?' : 'Confirm',
    \ '!'  : 'Shell',
    \ 't'  : 'Terminal'
    \}
set statusline=%#Search#
set statusline+=\ %{toupper(g:currentmode[mode()])}
set statusline+=\ %#StatusLine#
set statusline+=\ %f%m%r%h%w
set statusline+=\ %#CursorLine#%{StatuslineGit()}%#StatusLine#
set statusline+=%#StatusLine#
set statusline+=%=
set statusline+=\ %#CursorLine#
set statusline+=\ %y
set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
set statusline+=\ %L\ %l:%c

"" }}}

"####################################################################
" plug options and mappings {{{
"####################################################################

" colorscheme fixes for lightspeed, adapted from shaunsingh/nord.nvim
autocmd ColorScheme nord highlight LightspeedLabel guifg=#88C0D0 gui=bold
autocmd ColorScheme nord highlight LightspeedLabelOverlapped guifg=#88C0D0 gui=bold,underline
autocmd ColorScheme nord highlight LightspeedLabelDistant guifg=#B48EAD gui=bold
autocmd ColorScheme nord highlight LightspeedLabelDistantOverlapped guifg=#B48EAD gui=bold,underline
autocmd ColorScheme nord highlight LightspeedShortcut guifg=#5E81AC gui=bold
autocmd ColorScheme nord highlight LightspeedShortcutOverlapped guifg=#5E81AC gui=bold,underline
autocmd ColorScheme nord highlight LightspeedMaskedChar guifg=#434C5E gui=bold
autocmd ColorScheme nord highlight LightspeedGreyWash guifg=#616E88
autocmd ColorScheme nord highlight LightspeedUnlabeledMatch guifg=#D8DEE9 guibg=#3B4252
autocmd ColorScheme nord highlight LightspeedOneCharMatch guifg=#88C0D0 gui=bold,reverse
autocmd ColorScheme nord highlight LightspeedUniqueChar gui=bold,underline

" colorscheme from plug
colorscheme nord

" GitGutter
nnoremap <silent><leader>g :GitGutterToggle<cr>

" Undo Tree
nnoremap <silent><leader>u :UndotreeToggle<cr>:UndotreeFocus<cr>
"" }}}

"####################################################################
" golang settings {{{
"####################################################################
" dlv plug
lua require('dap-go').setup()
lua << EOF
require("dapui").setup({
  sidebar = {
    elements = {
      { id = "scopes", size = 0.6 },
      { id = "stacks", size = 0.2 },
      { id = "breakpoints", size = 0.2 },
    },
    size = 40,
    position = "left",
  },
  tray = {
    elements = { "repl" },
    size = 16,
    position = "bottom",
  },
})
EOF
autocmd FileType dapui* set statusline=\ %f
autocmd FileType dap-repl set statusline=\ %f
lua require("nvim-dap-virtual-text").setup()

au FileType go nmap <silent><leader>b :lua require'dap'.toggle_breakpoint()<cr>
au FileType go nmap <silent><leader>B :lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>

au FileType go nmap <silent><leader>k :lua require("dapui").eval()<cr>
au FileType go nmap <silent><leader>D :lua require("dapui").toggle()<cr>

au FileType go nmap <silent><leader>d :lua require('dap').continue()<cr>
au FileType go nmap <silent><leader>c :lua require('dap').continue()<cr>
au FileType go nmap <silent><leader>C :lua require("dap").run_to_cursor()<cr>
au FileType go nmap <silent><leader>s :lua require('dap').step_over()<cr>
au FileType go nmap <silent><leader>i :lua require('dap').step_into()<cr>
au FileType go nmap <silent><leader>o :lua require('dap').step_out()<cr>
au FileType go nmap <silent><leader>fd :lua require('dap').down()<cr>
au FileType go nmap <silent><leader>fu :lua require('dap').up()<cr>
au FileType go nmap <silent><leader>q :lua require('dap').terminate()<cr>:lua require('dap').repl.close()<cr>:lua require("dapui").close()<cr>:lua require("nvim-dap-virtual-text").disable()<cr>

au FileType go nmap <silent><leader>td :lua require('dap-go').debug_test()<cr>

" gopher plug
au FileType go nmap <leader>tc :GoCoverage toggle<cr>

" go lsp setup:
lua <<EOF
  lspconfig = require "lspconfig"
  lspconfig.gopls.setup {
    cmd = {"gopls", "serve"},
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
        },
        staticcheck = true,
      },
    },
  }
EOF

" go imports taken from https://github.com/golang/tools/blob/master/gopls/doc/vim.md#neovim-imports
lua <<EOF
  function goimports(timeout_ms)
    local context = { only = { "source.organizeImports" } }
    vim.validate { context = { context, "t", true } }

    local params = vim.lsp.util.make_range_params()
    params.context = context

    -- See the implementation of the textDocument/codeAction callback
    -- (lua/vim/lsp/handler.lua) for how to do this properly.
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, timeout_ms)
    if not result or next(result) == nil then return end
    local actions = result[1].result
    if not actions then return end
    local action = actions[1]

    -- textDocument/codeAction can return either Command[] or CodeAction[]. If it
    -- is a CodeAction, it can have either an edit, a command or both. Edits
    -- should be executed first.
    if action.edit or type(action.command) == "table" then
      if action.edit then
        vim.lsp.util.apply_workspace_edit(action.edit)
      end
      if type(action.command) == "table" then
        vim.lsp.buf.execute_command(action.command)
      end
    else
      vim.lsp.buf.execute_command(action)
    end
  end
EOF
autocmd BufWritePre *.go lua goimports(1000)

" auto gofmt
autocmd BufWritePre *.go lua vim.lsp.buf.formatting()

" go lsp specific bindings
au FileType go nmap gr :lua vim.lsp.buf.references()<cr>:lua vim.lsp.buf.document_highlight()<cr>
au FileType go nmap gd :lua vim.lsp.buf.definition()<cr>
au FileType go nmap gi :lua vim.lsp.buf.implementation()<cr>
au FileType go nmap <leader>m :lua vim.lsp.buf.document_symbol()<cr>
au FileType go nmap <leader>f :lua vim.lsp.buf.formatting()<cr>
au FileType go nmap <leader>r :lua vim.lsp.buf.rename()<cr>
au FileType go nmap K :lua vim.lsp.buf.hover()<cr>
au FileType go nmap <leader>h :lua vim.lsp.buf.document_highlight()<cr>
au FileType go nmap <leader>H :lua vim.lsp.buf.clear_references()<cr>

" highlighing rules for document_highlight
highlight LspReference guifg=NONE guibg=#B48EAD guisp=NONE gui=NONE cterm=NONE ctermfg=NONE ctermbg=59
highlight! link LspReferenceText LspReference
highlight! link LspReferenceRead LspReference
highlight! link LspReferenceWrite LspReference
"" }}}
