---------------------------------------------------------------- Dependencies
-- Dependencies that are generally available.

-- repo: https://github.com/nvim-lua/plenary.nvim
-- config: none
-- used by: telescope, null-ls
vim.cmd("packadd plenary.nvim")

-- repo: https://github.com/MunifTanjim/nui.nvim
-- config: none
-- used by: noice.nvim
vim.cmd("packadd nui.nvim")

-- repo: https://github.com/rcarriga/nvim-notify
-- config: none
-- used by: noice.nvim
vim.cmd("packadd nvim-notify")

---------------------------------------------------------------- Visuals
-- Visual enhancements to nvim.

-- repo: https://github.com/rebelot/kanagawa.nvim
-- config: ./plugins/kanagawa.lua
vim.cmd("packadd kanagawa.nvim")
require("plugins/kanagawa")

-- repo: https://github.com/nvim-lualine/lualine.nvim
-- config: ./plugins/lualine.lua
vim.cmd("packadd lualine.nvim")
require("plugins/lualine")

-- repo: https://github.com/echasnovski/mini.indentscope
-- config: ./plugins/mini-indentscope.lua
vim.cmd("packadd mini.indentscope")
require("plugins/mini-indentscope")

-- repo: https://github.com/karb94/neoscroll.nvim
-- config: ./plugins/neoscroll.lua
vim.cmd("packadd neoscroll.nvim")
require("neoscroll").setup()

-- repo: https://github.com/folke/noice.nvim
-- config: ./plugins/noice.lua
vim.cmd("packadd noice.nvim")
require("plugins/noice")

-- repo: https://github.com/nvim-treesitter/nvim-treesitter
-- config: ./plugins/nvim-treesitter.lua
-- dependencies:
--  * https://github.com/nvim-treesitter/nvim-treesitter-textobjects
vim.cmd("packadd nvim-treesitter")
vim.cmd("packadd nvim-treesitter-textobjects") -- dependency for nvim-treesitter
require("plugins/nvim-treesitter")

-- repo: https://github.com/akinsho/toggleterm.nvim
-- config: ./plugins/toggleterm.lua
vim.cmd("packadd toggleterm.nvim")
require("plugins/toggleterm")

---------------------------------------------------------------- Movement
-- Additional movements that go beyond stock vi.

-- repo: https://github.com/ggandor/leap.nvim
-- config: ./plugins/leap.lua
vim.cmd("packadd leap.nvim")
require("plugins/leap")

-- repo: https://github.com/echasnovski/mini.jump
-- config: ./plugins/mini-jump.lua
vim.cmd("packadd mini.jump")
require("plugins/mini-jump")

-- repo: https://github.com/mfussenegger/nvim-treehopper
-- config: ./plugins/nvim-treehopper.lua
vim.cmd("packadd nvim-treehopper")
require("plugins/nvim-treehopper")

---------------------------------------------------------------- Text
-- Text-related mappings, completions, and text-objects.

-- repo: https://github.com/echasnovski/mini.ai
-- config: none
vim.cmd("packadd mini.ai")
require("mini.ai").setup()

-- repo: https://github.com/echasnovski/mini.comment
-- config: none
vim.cmd("packadd mini.comment")
require("mini.comment").setup()

-- repo: https://github.com/echasnovski/mini.surround
-- config: none
vim.cmd("packadd mini.surround")
require("mini.surround").setup({ search_method = "cover_or_next" })

-- repo: https://github.com/echasnovski/mini.trailspace
-- config: ./plugins/mini-traispace.lua
vim.cmd("packadd mini.trailspace")
require("plugins/mini-trailspace")

-- repo: https://github.com/windwp/nvim-autopairs
-- config: ./plugins/nvim-autopairs.lua
vim.cmd("packadd nvim-autopairs")
require("nvim-autopairs").setup()

-- repo: https://github.com/tpope/vim-sleuth
-- config: none
vim.cmd("packadd vim-sleuth")

-- repo: https://github.com/gbprod/yanky.nvim
-- config: ./plugins/yanky.lua
vim.cmd("packadd yanky.nvim")
require("plugins/yanky")

---------------------------------------------------------------- Integration
-- Integration of external software.

if vim.fn.executable("git") == 1 then
  -- repo: https://github.com/lewis6991/gitsigns.nvim
  -- config: none
  vim.cmd("packadd gitsigns.nvim")
  require("gitsigns").setup()
end

-- repo: https://github.com/samjwill/nvim-unception
-- config: none
vim.cmd("packadd nvim-unception")

if vim.fn.executable("ranger") == 1 then
  -- repo: https://github.com/kevinhwang91/rnvimr
  -- config: ./plugins/rnvimr.lua
  vim.cmd("packadd rnvimr")
  require("plugins/rnvimr")
end

---------------------------------------------------------------- IDE Features
-- Autocompletion, language servers and debuggers.

-- repo: https://git.sr.ht/~whynothugo/lsp_lines.nvim
-- config: ./plugins/lsp_lines.lua
vim.cmd("packadd lsp_lines.nvim")
require("plugins/lsp_lines")

-- repo: https://github.com/jose-elias-alvarez/null-ls.nvim
-- config: ./plugins/null-ls.lua
vim.cmd("packadd null-ls.nvim")
require("plugins/null-ls")

-- repo: https://github.com/hrsh7th/nvim-cmp
-- config: ./plugins/nvim-cmp.lua
-- dependencies:
--  * https://github.com/hrsh7th/cmp-nvim-lsp
--  * https://github.com/hrsh7th/cmp-buffer
vim.cmd("packadd cmp-nvim-lsp")
vim.cmd("packadd cmp-buffer")
vim.cmd("packadd nvim-cmp")
require("plugins/nvim-cmp")

-- repo: https://github.com/mfussenegger/nvim-dap
-- config: ./plugins/nvim-dap.lua
vim.cmd("packadd nvim-dap")
require("plugins/nvim-dap")

-- repo: https://github.com/neovim/nvim-lspconfig
-- config: ./plugins/nvim-lspconfig.lua
vim.cmd("packadd nvim-lspconfig")
require("plugins/nvim-lspconfig")

-- repo: https://github.com/RRethy/vim-illuminate
-- config: ./plugins/vim-illuminate.lua
vim.cmd("packadd vim-illuminate")
require("plugins/vim-illuminate")

---------------------------------------------------------------- Language Support
-- Language specific plugins

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("plugin_filetype_go", {}),
  pattern = "go",
  callback = function()
    -- repo: https://github.com/leoluz/nvim-dap-go
    -- config: ./plugins/nvim-dap-go.lua
    vim.cmd("packadd nvim-dap-go")
    require("plugins/nvim-dap-go")

    -- repo: https://github.com/rafaelsq/nvim-goc.lua
    -- config: ./plugins/nvim-goc.lua
    vim.cmd("packadd nvim-goc.lua")
    require("plugins/nvim-goc")
  end,
})

---------------------------------------------------------------- Extra Views
-- Plugins that provide additional views or windows.

-- repo: https://github.com/anuvyklack/hydra.nvim
-- config: ./plugins/hydra.lua
-- dependencies:
--  * gitsigns.nvim
--  * nvim-dap
vim.cmd("packadd hydra.nvim")
require("plugins/hydra")

-- repo: https://github.com/nvim-telescope/telescope.nvim
-- config: ./plugins/telescope.lua
-- dependencies:
--  * noice.nvim
vim.cmd("packadd telescope.nvim")
require("plugins/telescope")

-- repo: https://github.com/mbbill/undotree
-- config: ./plugins/undotree.lua
vim.cmd("packadd undotree")
require("plugins/undotree")

-- repo: https://github.com/folke/which-key.nvim
-- config: ./plugins/which-key.lua
vim.cmd("packadd which-key.nvim")
require("plugins/which-key")
