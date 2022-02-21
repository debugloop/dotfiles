-- vim: set ts=2 sw=2 et:
return require('packer').startup({function(use)
  use { -- plugin manager
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

  -- visual plugins
  use { -- colorscheme
    "rebelot/kanagawa.nvim",
    config = function ()
      require('kanagawa').setup({
        -- default colors
        colors = {},
        overrides = {},
        -- no fancy term features
        undercurl = false,
        transparent = false,
        -- no special styling such as bold or italic
        commentStyle = "NONE",
        functionStyle = "NONE",
        keywordStyle = "NONE",
        statementStyle = "NONE",
        typeStyle = "NONE",
        variablebuiltinStyle = "NONE",
        -- no extra splashes of color
        specialReturn = false,
        specialException = false,
      })

      -- setup must be called before loading
      vim.cmd("colorscheme kanagawa")
    end
  }

  use { -- smooth scrolling
    'karb94/neoscroll.nvim',
    config = function()
      require('neoscroll').setup({})
    end
  }

  use{ -- nice folds with previews
    'anuvyklack/pretty-fold.nvim',
     config = function()
        require('pretty-fold').setup{}
        require('pretty-fold.preview').setup({ key = 'l' })
     end
  }

  use { -- git status in sign column (as well as some mappings and text objects)
    'lewis6991/gitsigns.nvim',
    requires = { 'nvim-lua/plenary.nvim', 'folke/which-key.nvim' },
    config = function()
      require('gitsigns').setup({
        signcolumn = true,
        keymaps = {
          noremap = true,
          ['o ig'] = ':<C-U>Gitsigns select_hunk<cr>',
          ['x ig'] = ':<C-U>Gitsigns select_hunk<cr>'
        },
      })
      require('which-key').register({
        ["<leader>gt"] = { require('gitsigns').toggle_signs, "git: toggle signs" },
        ["]g"] = { function() for i=1,vim.v.count1 do require('gitsigns').next_hunk({wrap = true, navigation_message = false}) end end, "jump to next git hunk" },
        ["[g"] = { function() for i=1,vim.v.count1 do require('gitsigns').prev_hunk({wrap = true, navigation_message = false}) end end, "jump to next git hunk" },
        ["<leader>gs"] = { require('gitsigns').stage_hunk, "git: stage hunk" },
        ["<leader>gu"] = { require('gitsigns').undo_stage_hunk, "git: undo stage hunk" },
        ["<leader>gr"] = { require('gitsigns').reset_hunk, "git: reset hunk" },
        ["<leader>gR"] = { require('gitsigns').reset_buffer, "git: reset buffer" },
        ["<leader>gd"] = { require('gitsigns').preview_hunk, "git: diff hunk" },
        ["<leader>gb"] = { require('gitsigns').blame_line, "git: blame line" },
        ["<leader>gS"] = { require('gitsigns').stage_buffer, "git: stage buffer" },
        ["<leader>gU"] = { require('gitsigns').reset_buffer_index, "git: undo stage buffer" },
      })
      require('which-key').register({
        ["<leader>gs"] = { require('gitsigns').stage_hunk, "git: stage" },
        ["<leader>gr"] = { require('gitsigns').reset_hunk, "git: reset" },
      }, { mode = "v" })
    end
  }

  use { -- render colors when referenced
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

  use { -- visual help for mappings
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

  use { -- visualize undo tree
    'mbbill/undotree',
    requires = { 'folke/which-key.nvim' },
    cmd = {'UndotreeToggle'},
    config = function()
      require('which-key').register({
        ["<leader>u"] = { "<cmd>UndotreeToggle<cr><cmd>UndotreeFocus<cr>", "toggle undo tree" },
      })
    end
  }

  use { -- browse dirs with `-`
    'justinmk/vim-dirvish'
  }

  use { -- tabline and statusline (as well as some basic text editing stuff)
    'echasnovski/mini.nvim',
    config = function()
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
      require('mini.tabline').setup({
        show_icons = false,
        set_vim_settings = true
      })
      vim.api.nvim_command([[
      highlight! link MiniTablineVisible MiniTablineHidden
      ]])
      -- these are not visual plugins but basic text editing helpers
      require('mini.comment').setup()
      require('mini.completion').setup()
      vim.api.nvim_set_keymap('i', [[<Tab>]],   [[pumvisible() ? "\<C-n>" : "\<Tab>"]],   { noremap = true, expr = true })
      vim.api.nvim_set_keymap('i', [[<S-Tab>]], [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { noremap = true, expr = true })
      require('mini.indentscope').setup({
        symbol = 'ˑּ'
      })
      require('mini.jump').setup()
      vim.api.nvim_command([[
      highlight MiniJump guibg=NONE guifg=#1f1f28 guibg=#ffa066
      ]])
      require('mini.surround').setup()
      require('mini.trailspace').setup()
      vim.api.nvim_command([[
      highlight MiniTrailspace guibg=NONE guifg=#1f1f28 guibg=#e82424
      ]])
      require('which-key').register({
        ["<leader>w"] = { require('mini.trailspace').trim, "trim trailing whitespace"},
      })
    end
  }

  -- text editing
  use { -- never bother with indent
    'tpope/vim-sleuth'
  }

  use { -- two char jump on S
    'phaazon/hop.nvim',
    config = function()
      require('hop').setup({})
      -- TODO: somehow this clunky triple require is needed to accept not only the last mapping
      require('which-key').register({
        ["S"] = { require('hop').hint_char2, "hop anywhere with two chars"},
      })
      require('which-key').register({
        ["S"] = { require('hop').hint_char2, "hop anywhere with two chars", mode = "v" },
      })
      require('which-key').register({
        ["S"] = { require('hop').hint_char2, "hop anywhere with two chars", mode = "o" },
      })
      vim.api.nvim_command([[
        highlight HopNextKey guibg=NONE guifg=#1f1f28 guibg=#ffa066
      ]])
    end
  }

  -- treesitter syntax
  use { -- treesitter itself, with fancy text objects
    'nvim-treesitter/nvim-treesitter',
    requires = { 'nvim-treesitter/nvim-treesitter-textobjects', 'folke/which-key.nvim' },
    run = ':TSUpdate',
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = "maintained",
        highlight = {
          enable = true,
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["aC"] = "@class.outer",
              ["iC"] = "@class.inner",
              ["ac"] = "@conditional.outer",
              ["ic"] = "@conditional.inner",
              ["ab"] = "@block.outer",
              ["ib"] = "@block.inner",
              ["al"] = "@loop.outer",
              ["il"] = "@loop.inner",
              ["is"] = "@statement.inner",
              ["as"] = "@statement.outer",
              ["ad"] = "@comment.outer",
              ["am"] = "@call.outer",
              ["im"] = "@call.inner"
            },
          },
          move = {
            enable = enable,
            set_jumps = true,
            goto_next_start = {
              ["]]"] = "@function.outer",
            },
            goto_next_end = {
              ["]["] = "@function.outer",
            },
            goto_previous_start = {
              ["[["] = "@function.outer",
            },
            goto_previous_end = {
              ["[]"] = "@function.outer",
            },
          },
        },
      })
      -- TODO: if the move section above worked, I wouldn't need these:
      require('which-key').register({
        ["]]"] = { function() for i=1,vim.v.count1 do vim.api.nvim_command("TSTextobjectGotoNextStart @function.outer") end end, "jump to next function" },
        ["[["] = { function() for i=1,vim.v.count1 do vim.api.nvim_command("TSTextobjectGotoPreviousStart @function.outer") end end, "jump to previous function" },
      })
    end
  }

  use {
    'mfussenegger/nvim-treehopper',
    config = function()
      -- TODO: figure out how the following work in which-key
      vim.api.nvim_command([[
        omap     <silent> m :<C-U>lua require('tsht').nodes()<CR>
        vnoremap <silent> m :lua require('tsht').nodes()<CR>
        highlight TSNodeKey guibg=NONE guifg=#1f1f28 guibg=#ffa066
      ]])
    end
  }

  use {
    'romgrk/nvim-treesitter-context',
    config = function()
      require('treesitter-context').setup({
        enable = true,
        max_lines = 1,
        patterns = {
          default = {
            'function',
            'method',
          },
        },
      })
    end
  }

  use { -- set commentstring from treesitter, used by mini.comment above
    'JoosepAlviste/nvim-ts-context-commentstring',
    requires = { 'nvim-treesitter/nvim-treesitter' }
  }

  -- lsp
  use { -- lsp configuration, mappings, autocommands
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
        on_attach = function(client, bufnr)
          require('illuminate').on_attach(client)
          require('which-key').register({
            ["K"] = { vim.lsp.buf.hover, "lsp: show help" },
            ["gr"] = { vim.lsp.buf.references, "lsp: show references" },
            ["gd"] = { vim.lsp.buf.definition, "lsp: goto type definition" },
            ["gi"] = { vim.lsp.buf.implementation, "lsp: show implementations" },
            ["<leader>m"] = { vim.lsp.buf.document_symbol, "lsp: map all symbols" },
            ["<leader>f"] = { vim.lsp.buf.formatting, "lsp: run formatter" },
            ["<leader>r"] = { vim.lsp.buf.rename, "lsp: rename symbol" },
            ["<leader>?"] = { vim.lsp.buf.code_action, "lsp: run code action" },
            ["]d"] = { function() for i=1,vim.v.count1 do vim.diagnostic.goto_next() end end, "jump to next diagnostic" },
            ["[d"] = { function() for i=1,vim.v.count1 do vim.diagnostic.goto_prev() end end, "jump to previous diagnostic" },
            ["]r"] = { function() for i=1,vim.v.count1 do require('illuminate').next_reference({wrap=true, silent=true}) end end, "jump to next reference" },
            ["[r"] = { function() for i=1,vim.v.count1 do require('illuminate').next_reference({wrap=true, reverse=true, silent=true}) end end, "jump to previous reference" },
            ["<leader>it"] = { require('illuminate').toggle_pause, "illuminate: toggle updates" },
          }, { buffer = bufnr })
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
      ]], false)
    end
  }

  use { -- highlight references for lsp
    'RRethy/vim-illuminate',
    ft = "go"
  }

  -- debugging
  use { -- nvim startup profiling
    'tweekmonster/startuptime.vim',
    cmd = "StartupTime"
  }

  use { -- debug adapter
    'mfussenegger/nvim-dap',
    requires = { 'folke/which-key.nvim' },
    config = function()
      require('which-key').register({
        ["<leader>k"] = { require('dap.ui.widgets').hover, "debug: show value", mode = "v" },
        ["<leader>b"] = {  require('dap').toggle_breakpoint, "debug: toggle breakpoint" },
        ["<leader>B"] = {  function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, "debug: set conditional breakpoint" },
        ["<leader>d"] = {  function() dap = require('dap'); dap.terminate(); dap.continue(); end, "debug: start or restart" },
        ["<leader>c"] = {  require('dap').continue, "debug: continue or start" },
        ["<leader>C"] = {  require('dap').run_to_cursor, "debug: continue to cursor" },
        ["<leader>s"] = {  require('dap').step_over, "debug: step" },
        ["<leader>i"] = {  require('dap').step_into, "debug: step into" },
        ["<leader>o"] = {  require('dap').step_out, "debug: step out" },
        ["<leader>fd"] = { require('dap').down, "debug: frame down" },
        ["<leader>fu"] = { require('dap').up, "debug: frame up" },
        ["<leader>q"] = {  function() dap = require('dap'); dap.terminate(); dap.repl.close(); end, "quit debugging" },
        ["<leader>Q"] = {  function() dap = require('dap'); dap.terminate(); dap.repl.close(); require("dap.breakpoints").clear(); require('dapui').close() end, "quit debugging and clear breakpoints" },
      })
    end
  }

  use { -- debug ui
    'rcarriga/nvim-dap-ui',
    requires = { 'folke/which-key.nvim', 'mfussenegger/nvim-dap' },
    ft = "go", -- just the languages which have their adapter installed
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
        ["<leader>k"] = { require('dapui').eval, "debug: show value" },
        ["<leader>D"] = { require('dapui').toggle, "debug: toggle view" },
      })
    end
  }

  -- language support
  use { -- debug module for go
    'leoluz/nvim-dap-go',
    requires = { 'folke/which-key.nvim', 'mfussenegger/nvim-dap' },
    ft = "go",
    config = function ()
      require('dap-go').setup()
      require('which-key').register({
        ["<leader>td"] = { require('dap-go').debug_test, "test: start debugging closest" },
      })
    end
  }

  use { -- go test coverage
    'rafaelsq/nvim-goc.lua',
    requires = { 'folke/which-key.nvim' },
    ft = "go",
    config = function ()
      vim.opt.switchbuf = 'useopen'
      local goc = require'nvim-goc'
      goc.setup({ verticalSplit = false })
      require('which-key').register({
        ["<leader>tc"] = { require('nvim-goc').Coverage, "test: show coverage" },
        ["<leader>tf"] = { require('nvim-goc').CoverageFunc, "test: show coverage for function" },
        ["<leader>tC"] = { require('nvim-goc').ClearCoverage, "test: clear coverage" },
        ["<leader>a"] = { require('nvim-goc').Alternate, "goto or create test file" },
      })
    end
  }

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
