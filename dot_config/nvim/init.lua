-- bootstrap packer (https://github.com/wbthomason/packer.nvim#bootstrapping)
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

-- include classic vimrc
vim.cmd [[source ~/.vimrc]]

-- set neovim only options
vim.opt.undofile = true  -- undofiles between vim and nvim are incompatible
vim.opt.undodir = "/home/danieln/.undo/"
vim.opt.backup = true  -- no backups on servers (vim), just on localhost (nvim)
vim.opt.backupdir = "/home/danieln/.backup/"
vim.opt.showmode = false  -- cursor and statusline show this already
vim.opt.termguicolors = true  -- proper colors

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldnestmax=1

-- set neovim only options that are not lua-ready yet
vim.api.nvim_exec([[
syntax off

" exceptions to backup setting (gopass edit is in /dev/shm/*)
autocmd BufRead,BufNewFile /dev/* set nobackup
autocmd BufRead,BufNewFile /dev/* set noundofile

" highlight yanked
au TextYankPost * lua vim.highlight.on_yank {higroup="IncSearch", timeout=300, on_visual=true}

" quickfix usability, some plugins use this heavily
map <C-n> :cnext<cr>
map <C-m> :cprevious<cr>
nnoremap <expr> <C-c> !empty(filter(tabpagebuflist(), 'getbufvar(v:val, "&buftype") is# "quickfix"')) ? ':cclose<cr>' : ':nohl<cr>'

]], false)

-- include plugins
require('plugins')
