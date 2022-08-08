return require('packer').startup(function(use)
  use({
    'wbthomason/packer.nvim',  -- self-manage
    config = function ()
      -- make packer sync automatically after editing this file
      vim.api.nvim_create_autocmd('BufWritePost', {
        group = vim.api.nvim_create_augroup('on_save_nvim_plugins', {}),
        pattern = "plugins.lua",
        callback = function()
          vim.cmd('source ~/.config/nvim/init.lua')
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

  use { -- mapping modes
    'anuvyklack/hydra.nvim',
  }

  use({ -- beautify folds
    'anuvyklack/pretty-fold.nvim',
    config = function()
      require('pretty-fold').setup()
    end
  })

  use({ -- preview folds
    'anuvyklack/fold-preview.nvim',
    requires = 'anuvyklack/keymap-amend.nvim',
    config = function()
      require('fold-preview').setup({default_keybindings = false})

      vim.keymap.set('n', 'l',  function() require('fold-preview').mapping.show_close_preview_open_fold(function() for i=1,vim.v.count1 do vim.api.nvim_feedkeys("l", "n", true) end end) end)
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
    require = { "anuvyklack/hydra.nvim" },
    config = function()
      require('gitsigns').setup()
      local hint = [[
 _s_: stage hunk  _S_: stage buffer     _u_: undo last stage  _U_: unstage buffer
 _J_: next hunk   _K_: previous hunk    _p_: preview hunk     _C_: change base
 _b_: blame       _B_: blame with diff  _d_: toggle deleted   _w_: toggle word diff
 ^
 ^ ^              _q_/_<Esc>_: quit
]]

      local Hydra = require("hydra")
      Hydra({
        name = 'Git',
        hint = hint,
        config = {
          buffer = bufnr,
          color = 'pink',
          invoke_on_body = true,
          hint = {
            type = 'window',
            border = 'single',
            position = 'bottom'
          },
          on_enter = function()
            vim.cmd 'mkview'
            vim.cmd 'silent! %foldopen!'
            vim.bo.modifiable = false
            require('gitsigns').toggle_linehl(true)
          end,
          on_exit = function()
            local cursor_pos = vim.api.nvim_win_get_cursor(0)
            vim.cmd 'loadview'
            vim.api.nvim_win_set_cursor(0, cursor_pos)
            require('gitsigns').toggle_linehl(false)
            require('gitsigns').toggle_deleted(false)
          end,
        },
        mode = {'n','x'},
        body = '<leader>g',
        heads = {
          { 'J',
            function()
              if vim.wo.diff then return ']c' end
              vim.schedule(function() require('gitsigns').next_hunk() end)
              return '<Ignore>'
            end,
            { expr = true, desc = 'next hunk' } },
          { 'K',
            function()
              if vim.wo.diff then return '[c' end
              vim.schedule(function() require('gitsigns').prev_hunk() end)
              return '<Ignore>'
            end,
            { expr = true, desc = 'prev hunk' } },
          { 's', require('gitsigns').stage_hunk, { silent = true, nowait = true, desc = 'stage hunk' } },
          { 'S', require('gitsigns').stage_buffer, { desc = 'stage buffer' } },
          { 'u', require('gitsigns').undo_stage_hunk, { desc = 'undo last stage' } },
          { 'U', require('gitsigns').reset_buffer_index, { silent = true, nowait = true, desc = 'unstage all' } },
          { 'p', require('gitsigns').preview_hunk, { desc = 'preview hunk' } },
          { 'd', require('gitsigns').toggle_deleted, { nowait = true, desc = 'toggle deleted' } },
          { 'w', require('gitsigns').toggle_word_diff, { nowait = true, desc = 'toggle word diff' } },
          { 'b', require('gitsigns').blame_line, { desc = 'blame' } },
          { 'B', function() require('gitsigns').blame_line({ full = true }) end, { desc = 'blame show full' } },
          { 'C', function() require('gitsigns').change_base(vim.fn.input('Branch: ')) end, { desc = 'change base branch' } },
          { 'q', nil, { exit = true, nowait = true, desc = 'exit' } },
          { '<Esc>', nil, { exit = true, nowait = true, desc = 'exit' } }
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
        auto_install = true,
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
      vim.keymap.set('n', "gd", vim.lsp.buf.definition, { desc = "lsp: goto definition" })
      vim.keymap.set('n', "gD", vim.lsp.buf.declaration, { desc = "lsp: goto declaration" })
      vim.keymap.set('n', "gi", vim.lsp.buf.implementation, { desc = "lsp: list implementations" })
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

  use { -- better display of diagnostics
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
    require = { "anuvyklack/hydra.nvim" },
    config = function()
      vim.keymap.set('n', "<leader>b",  require('dap').toggle_breakpoint, { desc = "debug: toggle breakpoint" })
      vim.keymap.set('n', "<leader>B",  function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { desc = "debug: set conditional breakpoint" })

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup('on_dap_repl', {}),
        pattern = "dap-repl",
        callback = function()
          vim.cmd("startinsert")
        end,
      })

      local Hydra = require("hydra")
      local hint = [[
 _c_: continue      _s_: step over    _fu_: frame up         _e_: evaluate at cursor
 _C_: run to cursor _i_: step into    _fd_: frame down       _E_: evaluate expression
 _r_: open repl     _o_: step out     _b_: toggle breakpoint _B_: set conditional breakpoint
 ^
 ^ ^              _q_/_<Esc>_: quit              _Q_: quit and reset
]]

      Hydra({
        name = 'Debug',
        hint = hint,
        config = {
          color = 'pink',
          invoke_on_body = true,
          hint = {
            type = 'window',
            border = 'single',
            position = 'bottom'
          },
          on_enter = function()
            require('dap').continue();
          end,
          on_exit = function()
            require('dap').terminate()
          end
        },
        mode = {'n','x'},
        body = '<leader>d',
        heads = {
          { 'c',
            function()
              require('dap').continue()
            end,
            { desc = "continue or start" }
          },
          { 'C',
            function()
              require('dap').run_to_cursor()
            end,
            { desc = "run to cursor" }
          },
          { 's',
            function()
              require('dap').step_over()
            end,
            { desc = "step over" }
          },
          { 'i',
            function()
              require('dap').step_into()
            end,
            { desc = "step into" }
          },
          { 'o',
            function()
              require('dap').step_out()
            end,
            { desc = "step out" }
          },
          { 'fd',
            function()
              require('dap').down()
            end,
            { desc = "frame down" }
          },
          { 'fu',
            function()
              require('dap').up()
            end,
            { desc = "frame up" }
          },
          { 'e',
            function()
              require('dap.ui.widgets').preview()
            end,
            { desc = "evaluate value under cursor" }
          },
          { 'E',
            function()
              require('dap.ui.widgets').preview(vim.fn.input('Expression: '))
            end,
            { desc = "evaluate given expression" }
          },
          { 'b',
            function()
              require('dap').toggle_breakpoint()
            end,
            { desc = "toggle breakpoint" }
          },
          { 'B',
            function()
              require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
            end,
            { desc = "set conditional breakpoint" }
          },
          { 'r',
            function()
              require('dap').repl.toggle()
              vim.cmd("wincmd j")
            end,
            { desc = "debug: repl" }
          },
          { 'q',
            function()
              require('dap').repl.close()
            end,
            { desc = "quit", exit = true }
          },
          { '<Esc>',
            function()
              require('dap').repl.close()
            end,
            { desc = "quit", exit = true }
          },
          { 'Q',
            function()
              require('dap').repl.close()
              require("dap.breakpoints").clear()
              require('dapui').close()
            end,
            { desc = "quit and reset", exit = true }
          },
        }
      })
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
    branch = "fix-deprecated-hi-link",
    config = function ()
      require('nvim-goc').setup({ verticalSplit = false })
      vim.keymap.set('n', "<leader>tc",
        function()
          if goc_coverage_on == true then
            require('nvim-goc').ClearCoverage()
            goc_coverage_on = false
          else
            require('nvim-goc').Coverage()
            goc_coverage_on = true
          end
        end, { desc = "test: show coverage" })
      vim.keymap.set('n', "<leader>a", require('nvim-goc').Alternate, { desc = "goto or create test file" })
    end
  }

  if packer_bootstrap then
    require('packer').sync()
  end
end
)
