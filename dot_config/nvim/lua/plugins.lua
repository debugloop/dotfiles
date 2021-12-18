-- vim: set ts=2 sw=2 et:
return require('packer').startup({function(use)
  -- packer should manage itself
  use {
    'wbthomason/packer.nvim',
    config = function ()
      -- make packer sync automatically after editing this file
      vim.api.nvim_exec([[
      augroup on_save_nvim_plugins
      autocmd!
      autocmd BufWritePost plugins.lua source <afile> | PackerSync
      augroup end
      ]], false)
    end
  }

  use 'ggandor/lightspeed.nvim'

  use {
    'andersevenrud/nordic.nvim',
    config = function()
      require('nordic').colorscheme({
        underline_option = 'undercurl',
        italic = false,
        italic_comments = false,
      })
    end
  }

  -- improve all mappings with visual help
  use {
    'folke/which-key.nvim',
    config = function()
      require('which-key').setup({
        plugins = {
          spelling = {
            enabled = true,
            suggestions = 20,
          },
        },
      })
    end
  }

  use {
    "steelsojka/pears.nvim",
    config = function()
      require("pears").setup()
    end
  }

  use {
    'karb94/neoscroll.nvim',
    config = function()
      require('neoscroll').setup()
    end
  }

  -- treesitter syntax and friends
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = "maintained",
        highlight = {
          enable = true,
        }
      }
    end
  }
  use {
    'JoosepAlviste/nvim-ts-context-commentstring',
    requires = { 'nvim-treesitter/nvim-treesitter' }
  }

  -- lsp
  use {
    'neovim/nvim-lspconfig',
    ft = "go",
    requires = { 'folke/which-key.nvim', 'RRethy/vim-illuminate' },
    config = function()
      require("lspconfig").gopls.setup {
        cmd = {"gopls", "serve"},
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
          },
        },
        on_attach = function(client)
          require('illuminate').on_attach(client)
          vim.api.nvim_command([[
          highlight LspReference guibg=NONE guifg=#B48EAD gui=underline
          highlight! link LspReferenceText LspReference
          highlight! link LspReferenceRead LspReference
          highlight! link LspReferenceWrite LspReference
          ]])
        end
      }
      -- goimports function from https://github.com/golang/tools/blob/master/gopls/doc/vim.md#neovim-imports
      function goimports(timeout_ms)
        local context = { only = { "source.organizeImports" } }
        vim.validate { context = { context, "t", true } }

        local params = vim.lsp.util.make_range_params()
        params.context = context

        local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, timeout_ms)
        if not result or next(result) == nil then return end
        local actions = result[1].result
        if not actions then return end
        local action = actions[1]

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
      vim.api.nvim_exec([[
      augroup on_save_go
      autocmd BufWritePre *.go :lua goimports(1000)
      autocmd BufWritePre *.go :lua vim.lsp.buf.formatting()
      augroup end
      au FileType go nmap <silent>K :lua vim.lsp.buf.hover()<cr>
      ]], false)

      require('which-key').register({
        ["gr"] = { "<cmd>lua vim.lsp.buf.references()<cr>", "lsp: show references" },
        ["gd"] = { "<cmd>lua vim.lsp.buf.definition()<cr>", "lsp: goto definition" },
        ["gi"] = { "<cmd>lua vim.lsp.buf.implementation()<cr>", "lsp: show implementations" },
        ["<leader>m"] = { "<cmd>lua vim.lsp.buf.document_symbol()<cr>", "lsp: map all symbols" },
        ["<leader>f"] = { "<cmd>lua vim.lsp.buf.formatting()<cr>", "lsp: run formatter" },
        ["<leader>r"] = { "<cmd>lua vim.lsp.buf.rename()<cr>", "lsp: rename symbol" },
      })
    end
  }

  -- debugging
  use {
    'mfussenegger/nvim-dap',
    ft = "go",
    requires = { 'folke/which-key.nvim' },
    config = function()
      require('which-key').register({
        ["<leader>b"] = { "<cmd>lua require('dap').toggle_breakpoint()<cr>", "debug: toggle breakpoint" },
        ["<leader>B"] = { "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))", "debug: set conditional breakpoint" },
        ["<leader>d"] = { "<cmd>lua require('dap').continue()<cr>", "debug: start or continue" },
        ["<leader>c"] = { "<cmd>lua require('dap').continue()<cr>", "debug: continue or start" },
        ["<leader>C"] = { "<cmd>lua require('dap').run_to_cursor()<cr>", "debug: continue to cursor" },
        ["<leader>s"] = { "<cmd>lua require('dap').step_over()<cr>", "debug: step" },
        ["<leader>i"] = { "<cmd>lua require('dap').step_into()<cr>", "debug: step into" },
        ["<leader>o"] = { "<cmd>lua require('dap').step_out()<cr>", "debug: step out" },
        ["<leader>fd"] = { "<cmd>lua require('dap').down()<cr>", "debug: frame down" },
        ["<leader>fu"] = { "<cmd>lua require('dap').up()<cr>", "debug: frame up" },
        ["<leader>q"] = { "<cmd>lua require('dap').terminate()<cr><cmd>lua require('dap').repl.close()<cr><cmd>lua require('dapui').close()<cr><cmd>lua require('nvim-dap-virtual-text').disable()<cr>", "quit debugging" },
      })
    end
  }
  use {
    'rcarriga/nvim-dap-ui',
    requires = { 'folke/which-key.nvim' },
    ft = "go",
    config = function()
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
      vim.api.nvim_exec([[
      autocmd FileType dapui* set statusline=\ %f
      autocmd FileType dap-repl set statusline=\ %f

      ]], false)
      require('which-key').register({
        ["<leader>k"] = { "<cmd>lua require('dapui').eval()<cr>", "debug: show value" },
        ["<leader>D"] = { "<cmd>lua require('dapui').toggle()<cr>", "debug: toggle view" },
      })
    end
  }
  use {
    'theHamsta/nvim-dap-virtual-text',
    requires = { 'folke/which-key.nvim' },
    ft = "go",
    config = function()
      dapvt = require("nvim-dap-virtual-text")
      dapvt.setup()
      dapvt.disable()
      require('which-key').register({
        ["<leader>a"] = { "<cmd>lua require('nvim-dap-virtual-text').toggle()<cr>", "debug: toggle annotations" },
      })
    end
  }
  use {
    'leoluz/nvim-dap-go',
    requires = { 'folke/which-key.nvim' },
    ft = "go",
    config = function ()
      require('dap-go').setup()
      require('which-key').register({
        ["<leader>td"] = { "<cmd>lua require('dap-go').debug_test()<cr>", "test: start debugging closest" },
      })
    end
  }
  use {
    'arp242/gopher.vim',
    requires = { 'folke/which-key.nvim' },
    ft = "go",
    config = function ()
      require('which-key').register({
        ["<leader>tc"] = { "<cmd>GoCoverage toggle<cr>", "test: show coverage" },
      })
    end
  }

  -- visuals
  use {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.comment').setup()
      require('mini.completion').setup()
      vim.api.nvim_set_keymap('i', [[<Tab>]],   [[pumvisible() ? "\<C-n>" : "\<Tab>"]],   { noremap = true, expr = true })
      vim.api.nvim_set_keymap('i', [[<S-Tab>]], [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { noremap = true, expr = true })
      require('mini.tabline').setup({
        show_icons = false,
        set_vim_settings = true
      })
      vim.api.nvim_command([[
      highlight MiniTablineModifiedHidden guifg=#b48ead guibg=#373e4d
      ]])
      require('mini.statusline').setup({
        content = {
          active = function()
            local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
            local git           = MiniStatusline.section_git({ trunc_width = 75 })
            local diagnostics   = MiniStatusline.section_diagnostics({ trunc_width = 75, icon = "" })
            local filename      = MiniStatusline.section_filename({ trunc_width = 140 })
            local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 120 })
            local location      = MiniStatusline.section_location({ trunc_width = 75 })
            local search        = MiniStatusline.section_searchcount({ trunc_width = 75 })

            return MiniStatusline.combine_groups({
              { hl = mode_hl,                  strings = { mode } },
              { hl = 'MiniStatuslineDevinfo',  strings = { git, diagnostics } },
              '%<', -- Mark general truncate point
              { hl = 'MiniStatuslineFilename', strings = { filename } },
              '%=', -- End left alignment
              { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
              { hl = mode_hl,                  strings = { location, search } },
            })
          end
        },
        set_vim_settings = true,
      })
    end
  }

  use {
    'lewis6991/gitsigns.nvim',
    requires = { 'nvim-lua/plenary.nvim', 'folke/which-key.nvim' },
    config = function()
      require('gitsigns').setup({
        signcolumn = false
      })
      require('which-key').register({
        ["<leader>g"] = { "<cmd>Gitsigns toggle_signs<cr>", "toggle gitsigns" },
      })
    end
  }

  use {
    'norcalli/nvim-colorizer.lua',
    config = function ()
      require('colorizer').setup({
        "*",
        DEFAULT_OPTIONS = {
          RGB = true;
          RRGGBB = true;
          names = false;
          RRGGBBAA = true;
          rgb_fn = true;
        }
      })
    end
  }

  use {
    'pearofducks/ansible-vim',
    ft = { 'yaml', 'yaml.ansible' },
    config = function ()
      vim.api.nvim_exec([[
      au BufRead,BufNewFile ~/playbook/*.yml set filetype=yaml.ansible
      ]], false)
    end
  }
  use { 'dag/vim-fish', ft = 'fish' }
  use { 'ledger/vim-ledger', ft = 'ledger' }

  -- old-style plugins
  use {
    'mbbill/undotree',
    requires = { 'folke/which-key.nvim' },
    cmd = {'UndotreeToggle'},
    config = function()
      require('which-key').register({
        ["<leader>u"] = { "<cmd>UndotreeToggle<cr><cmd>UndotreeFocus<cr>", "toggle undo tree" },
      })
    end
  }

  use 'tpope/vim-sleuth'
  use 'justinmk/vim-dirvish'

  if packer_bootstrap then
    require('packer').sync()
  end
end,
config = {
  display = {
    open_fn = function()
      return require('packer.util').float({ border = 'none' })
    end
  }
}
})
