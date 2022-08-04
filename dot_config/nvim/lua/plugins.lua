return require('packer').startup(function(use)
  use({
    'wbthomason/packer.nvim',  -- self-manage
    config = function ()
      -- make packer sync automatically after editing this file
      vim.api.nvim_create_autocmd('BufWritePost', {
        group = vim.api.nvim_create_augroup('on_save_nvim_plugins', {}),
        pattern = "plugins.lua",
        callback = function()
          require("plugins")
          require('packer').sync()
        end
      })
    end
  })

  -- visual plugins
  use({ -- additional colors for variety
    "themercorp/themer.lua",
    config = function()
      require("themer").setup()
      vim.cmd("colorscheme themer_kanagawa")
      vim.keymap.set('n', '\\\\', '<cmd>COLORSCROLL<cr>', { desc = "switch colorscheme" })
    end
  })

  use { -- smooth scrolling
    'karb94/neoscroll.nvim',
    config = function()
      require('neoscroll').setup()
    end
  }

  use { -- git status in sign column (as well as some mappings and text objects)
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup()
      vim.keymap.set('n', '<leader>gt', require('gitsigns').toggle_signs, { desc = "git: toggle signs" })
      vim.keymap.set('n', "]g", function() for i=1,vim.v.count1 do require('gitsigns').next_hunk({wrap = true, navigation_message = false}) end end, { desc = "jump to next git hunk" })
      vim.keymap.set('n', "[g", function() for i=1,vim.v.count1 do require('gitsigns').prev_hunk({wrap = true, navigation_message = false}) end end, { desc = "jump to previous git hunk" })
      vim.keymap.set('n', "<leader>ga", require('gitsigns').stage_hunk, { desc = "git: stage hunk" })
      vim.keymap.set('n', "<leader>gA", require('gitsigns').stage_buffer, { desc = "git: stage buffer" })
      vim.keymap.set('n', "<leader>gu", require('gitsigns').undo_stage_hunk, { desc = "git: undo stage hunk" })
      vim.keymap.set('n', "<leader>gU", require('gitsigns').reset_buffer_index, { desc = "git: undo stage buffer" })
      vim.keymap.set('n', "<leader>gr", require('gitsigns').reset_hunk, { desc = "git: reset hunk" })
      vim.keymap.set('n', "<leader>gR", require('gitsigns').reset_buffer, { desc = "git: reset buffer" })
      vim.keymap.set('n', "<leader>gd", require('gitsigns').preview_hunk, { desc = "git: diff hunk" })
      vim.keymap.set('n', "<leader>gb", require('gitsigns').blame_line, { desc = "git: blame line" })
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
    config = function()
      vim.keymap.set('n', "<leader>u", function()
        vim.cmd("UndotreeToggle")
        vim.cmd("UndotreeFocus")
      end, { desc = "toggle undo tree" })
    end
  }

  use { -- browse dirs with `-`
    'justinmk/vim-dirvish',
  }

  use { -- mini plugin suite
    'echasnovski/mini.nvim',
    config = function()
      -- statusline
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
        }
      })

      -- tabline
      require('mini.tabline').setup()
      local current_hl = vim.api.nvim_get_hl_by_name('MiniTablineCurrent', {})
      current_hl.bold = true
      vim.api.nvim_set_hl(0, 'MiniTablineModifiedCurrent', current_hl)

      -- completion engine
      require('mini.completion').setup()
      vim.api.nvim_set_keymap('i', [[<Tab>]],   [[pumvisible() ? "\<C-n>" : "\<Tab>"]],   { noremap = true, expr = true })
      vim.api.nvim_set_keymap('i', [[<S-Tab>]], [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { noremap = true, expr = true })

      require('mini.ai').setup()  -- better text objects
      require('mini.comment').setup()  -- commenting
      require('mini.indentscope').setup({ symbol = 'ˑּ' }) -- show indent level as bar

      require('mini.jump').setup()  -- better f and t mappings
      vim.api.nvim_set_hl(0, 'MiniJump', { reverse = true })

      require('mini.jump2d').setup({ mappings = { start_jumping = 'S' } })  -- advanced jump on S
      vim.api.nvim_set_hl(0, 'MiniJump2dSpot', { reverse = true })

      require('mini.pairs').setup()  -- autocomplete pairs

      require('mini.surround').setup({ search_method = 'cover_or_next' })  -- change surroundings

      require('mini.trailspace').setup()  -- highlight and remove trailing spaces
      vim.api.nvim_set_hl(0, 'MiniTrailspace', { bg = "red" })
      vim.keymap.set('n', "<leader>w", require('mini.trailspace').trim, { desc = "trim trailing whitespace" })
    end
  }

  -- text editing
  use { -- never bother with indent, editorconfig and modeline support
    'tpope/vim-sleuth',
  }

  -- treesitter syntax
  use { -- treesitter itself, with fancy text objects
    'nvim-treesitter/nvim-treesitter',
    requires = { 'nvim-treesitter/nvim-treesitter-textobjects' },
    run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = "all",
        highlight = {
          enable = true,
        },
        -- incremental_selection = {
        --   enable = true,
        --   keymaps = {
        --     init_selection = "<cr>",
        --     node_incremental = "<cr>",
        --     node_decremental = "<s-cr>",
        --   },
        -- },
        indent = {
          enable = true
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
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
        },
      })

      vim.api.nvim_create_autocmd({'BufEnter','BufAdd','BufNew','BufNewFile','BufWinEnter'}, {
        group = vim.api.nvim_create_augroup('TS_FOLD_WORKAROUND', {}),
        callback = function()
          vim.opt.foldmethod     = 'expr'
          vim.opt.foldexpr       = 'nvim_treesitter#foldexpr()'
        end
      })

      vim.keymap.set('n', "]]", function() for i=1,vim.v.count1 do vim.api.nvim_command("TSTextobjectGotoNextStart @function.outer") end end, { desc = "go to next function" })
      vim.keymap.set('n', "[[", function() for i=1,vim.v.count1 do vim.api.nvim_command("TSTextobjectGotoPreviousStart @function.outer") end end, { desc = "go to previous function" })
    end
  }

  use { -- better incremental selection compared to stock treesitter
    'mfussenegger/nvim-treehopper',
    config = function()
      vim.keymap.set({'n', 'o', 'v'}, '<leader><space>', require('tsht').nodes, { desc = "select scope" })
      vim.api.nvim_set_hl(0, 'TSNodeKey', { reverse = true })
    end
  }

  -- lsp
  use { -- lsp configuration, mappings, autocommands
    'neovim/nvim-lspconfig',
    ft = "go",
    requires = { 'RRethy/vim-illuminate' },
    config = function()
      require("lspconfig").gopls.setup({
        on_attach = function(client, bufnr)
          require('illuminate').on_attach(client)
        end
      })

      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup('on_save_go_files', {}),
        pattern = { "*.go" },
        callback = function()
          vim.lsp.buf.format({async = false}, 3000) -- format first

          -- trhen handle imports
          local params = vim.lsp.util.make_range_params(nil, vim.lsp.util._get_offset_encoding())
          params.context = {only = {"source.organizeImports"}}

          local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
          for _, res in pairs(result or {}) do
            for _, r in pairs(res.result or {}) do
              if r.edit then
                vim.lsp.util.apply_workspace_edit(r.edit, vim.lsp.util._get_offset_encoding())
              else
                vim.lsp.buf.execute_command(r.command)
              end
            end
          end
        end,
      })

      vim.keymap.set('n', "K", vim.lsp.buf.hover, { desc = "lsp: show help" })
      vim.keymap.set('n', "gr", vim.lsp.buf.references, { desc = "lsp: show references" })
      vim.keymap.set('n', "gd", vim.lsp.buf.definition, { desc = "lsp: goto type definition" })
      vim.keymap.set('n', "<leader>m", vim.lsp.buf.document_symbol, { desc = "lsp: map all symbols" })
      vim.keymap.set('n', "<leader>f", vim.lsp.buf.formatting, { desc = "lsp: format file" })
      vim.keymap.set('n', "<leader>r", vim.lsp.buf.rename, { desc = "lsp: rename symbol" })
      vim.keymap.set('n', "<leader>?", vim.lsp.buf.code_action, { desc = "lsp: run code action" })
      vim.keymap.set('n', "]d", function() for i=1,vim.v.count1 do vim.diagnostic.goto_next() end end, { desc = "lsp: jump to next diagnostic" })
      vim.keymap.set('n', "[d", function() for i=1,vim.v.count1 do vim.diagnostic.goto_prev() end end, { desc = "lsp: jump to previous diagnostic" })
      vim.keymap.set('n', "]r", function() for i=1,vim.v.count1 do require('illuminate').next_reference({wrap=true, silent=true}) end end, { desc = "lsp: jump to next reference" })
      vim.keymap.set('n', "[r", function() for i=1,vim.v.count1 do require('illuminate').next_reference({wrap=true, reverse=true, silent=true}) end end, { desc = "lsp: jump to previous referenc" })
      vim.keymap.set('n', "<leader>I", require('illuminate').toggle_pause, { desc = "lsp: toggle reference illumination" })
    end
  }

  use {  -- better display of diagnostics
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    config = function()
      require("lsp_lines").setup()
      vim.diagnostic.config({
        virtual_text = false,
      })
    end,
  }

  use { -- highlight references, ideally with info from lsp
    'RRethy/vim-illuminate',
  }

  -- debugging
  use { -- nvim startup profiling
    'tweekmonster/startuptime.vim',
    cmd = "StartupTime"
  }

  use { -- debug adapter
    'mfussenegger/nvim-dap',
    config = function()
      vim.keymap.set('n', "<leader>b",  require('dap').toggle_breakpoint, { desc = "debug: toggle breakpoint" })
      vim.keymap.set('n', "<leader>B",  function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { desc = "debug: set conditional breakpoint" })
      vim.keymap.set('n', "<leader>d",  function() dap = require('dap'); dap.terminate(); dap.continue(); end, { desc = "debug: start or restart" })
      vim.keymap.set('n', "<leader>c",  require('dap').continue, { desc = "debug: continue or start" })
      vim.keymap.set('n', "<leader>C",  require('dap').run_to_cursor, { desc = "debug: continue to cursor" })
      vim.keymap.set('n', "<leader>s",  require('dap').step_over, { desc = "debug: step" })
      vim.keymap.set('n', "<leader>i",  require('dap').step_into, { desc = "debug: step into" })
      vim.keymap.set('n', "<leader>o",  require('dap').step_out, { desc = "debug: step out" })
      vim.keymap.set('n', "<leader>fd", require('dap').down, { desc = "debug: frame down" })
      vim.keymap.set('n', "<leader>fu", require('dap').up, { desc = "debug: frame up" })
      vim.keymap.set('n', "<leader>q",  function() dap = require('dap'); dap.terminate(); dap.repl.close(); end, { desc = "quit debugging" })
      vim.keymap.set('n', "<leader>Q",  function() dap = require('dap'); dap.terminate(); dap.repl.close(); require("dap.breakpoints").clear(); require('dapui').close() end, { desc = "quit debugging and clear breakpoints" })
    end
  }

  use { -- debug ui
    'rcarriga/nvim-dap-ui',
    requires = { 'mfussenegger/nvim-dap' },
    ft = "go", -- just the languages which have their adapter installed
    config = function()
      require("dapui").setup({
        layouts = {
          {
            elements = {
              'scopes',
              'breakpoints',
              'stacks',
              'watches',
            },
            size = 40,
            position = 'left',
          },
          {
            elements = {
              'repl',
              'console',
            },
            size = 10,
            position = 'bottom',
          },
        },
      })

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup('on_dap_windows', {}),
        pattern = "dap*",
        callback = function() vim.statusline = "" end,
      })
      vim.keymap.set('n', "<leader>k", require('dapui').eval, { desc = "debug: show value" })
      vim.keymap.set('n', "<leader>D", require('dapui').toggle, { desc = "debug: toggle view" })
    end
  }

  -- language support
  use { -- debug module for go
    'leoluz/nvim-dap-go',
    requires = { 'mfussenegger/nvim-dap' },
    ft = "go",
    config = function ()
      require('dap-go').setup()
      vim.keymap.set('n', "<leader>td", require('dap-go').debug_test, { desc = "test: start debugging closest" })
    end
  }

  use { -- go test coverage
    'ja-he/nvim-goc.lua',
    ft = "go",
    branch = "fix-deprecated-hi-link",
    config = function ()
      require('nvim-goc').setup({ verticalSplit = false })
      vim.keymap.set('n', "<leader>tc", require('nvim-goc').Coverage, { desc = "test: show coverage" })
      vim.keymap.set('n', "<leader>tf", require('nvim-goc').CoverageFunc, { desc = "test: show coverage for function" })
      vim.keymap.set('n', "<leader>tC", require('nvim-goc').ClearCoverage, { desc = "test: clear coverage" })
      vim.keymap.set('n', "<leader>a", require('nvim-goc').Alternate, { desc = "goto or create test file" })
    end
  }

  if packer_bootstrap then
    require('packer').sync()
  end
end
)
