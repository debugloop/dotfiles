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
Plug 'fatih/vim-go', {'for': 'go'}
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
inoremap <S-Tab> <C-x><C-o>

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
noremap <silent> H :call ToggleMovement('^', '0')<CR>
noremap L $

" jump to visual lines
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k

" move visual block
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

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
map <C-n> :cnext<CR>
map <C-m> :cprevious<CR>
nnoremap <expr> <C-c> !empty(filter(tabpagebuflist(), 'getbufvar(v:val, "&buftype") is# "quickfix"')) ? ':cclose<Cr>' : ':nohl<Cr>'

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
nnoremap <silent><leader>g :GitGutterToggle<Cr>

" Undo Tree
nnoremap <silent><leader>u :UndotreeToggle<Cr>:UndotreeFocus<Cr>

" vim-go
let g:go_list_type = "quickfix"
au FileType go nmap gr <Plug>(go-referrers)
au FileType go nmap gp <Plug>(go-channelpeers)
au FileType go nmap <leader>a <Plug>(go-alternate-edit)
au FileType go nmap <leader>c :GoCoverageToggle<cr>

lua << EOF
local nvim_lsp = require('lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

end
nvim_lsp.gopls.setup{}

EOF

"" }}}
