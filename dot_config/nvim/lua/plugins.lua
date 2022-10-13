return require('packer').startup(function(use)

  use({ -- preview folds
    'anuvyklack/fold-preview.nvim',
    requires = 'anuvyklack/keymap-amend.nvim',
    config = function()
      require('fold-preview').setup({ default_keybindings = false })
      vim.keymap.set('n', 'l', function()
        require('fold-preview').mapping.show_close_preview_open_fold(function()
          for _ = 1, vim.v.count1 do
            vim.api.nvim_feedkeys('l', 'n', true)
          end
        end
        )
      end
      )
    end
  })

  use({ -- mapping modes
    'anuvyklack/hydra.nvim',
    config = function()
      local Hydra = require('hydra')
      local hint = [[
            Options
 _v_ %{ve} set virtualedit
 _b_ %{bg} set background
 _l_ %{list} set list
 _s_ %{spell} set spell
 _c_ %{cux} draw crosshair
 _n_ %{nu} set number
 _r_ %{relativenumber} set relativenumber
 _i_ %{indentscope} set indentscope
 _I_ %{illuminate} set illuminate
 _L_ %{lsp} set lsp diagnostic      ]]
      Hydra({
        name = 'Options',
        hint = hint,
        config = {
          color = 'red',
          invoke_on_body = true,
          hint = {
            border = 'rounded',
            position = 'middle',
            funcs = {
              bg = function()
                if vim.o.background == "dark" then
                  return '[d]'
                else
                  return '[l]'
                end
              end,
              indentscope = function()
                if vim.g.miniindentscope_disable then
                  return '[ ]'
                else
                  return '[x]'
                end
              end,
              illuminate = function()
                if vim.g.illuminate_disable then
                  return '[ ]'
                else
                  return '[x]'
                end
              end,
              lsp = function()
                if lsp_display == nil then
                  lsp_display = 0
                end
                if lsp_display == 0 then
                  return '[x]'
                elseif lsp_display == 1 then
                  return '[v]'
                elseif lsp_display == 2 then
                  return '[ ]'
                end
              end,
            },
          },
        },
        mode = {'n', 'x'},
        body = '<leader>o',
        heads = {
          { 'n',
            function()
              if vim.o.number == true then
                vim.o.number = false
              else
                vim.o.number = true
              end
            end,
            { desc = 'set number' }
          },
          { 'b',
            function()
              if vim.o.background == "dark" then
                vim.o.background = "light"
              else
                vim.o.background = "dark"
              end
            end,
            { desc = 'set background' }
          },
          { 'r',
            function()
              if vim.o.relativenumber == true then
                vim.o.relativenumber = false
              else
                vim.o.relativenumber = true
              end
            end,
            { desc = 'set relativenumber' }
          },
          { 'i',
            function()
              if vim.g.miniindentscope_disable == true then
                vim.g.miniindentscope_disable = false
              else
                vim.g.miniindentscope_disable = true
              end
            end,
            { desc = 'set indentscope' }
          },
          { 'I',
            function()
              require('illuminate').toggle()
              vim.g.illuminate_disable = not vim.g.illuminate_disable
            end,
            { desc = 'set illuminate' }
          },
          { 'v',
            function()
              if vim.o.virtualedit == 'all' then
                vim.o.virtualedit = 'block'
              else
                vim.o.virtualedit = 'all'
              end
            end,
            { desc = 'set virtualedit' }
          },
          { 'l',
            function()
              if vim.o.list == true then
                vim.o.list = false
              else
                vim.o.list = true
              end
            end,
            { desc = 'set list' }
          },
          { 'L',
            function()
              if lsp_display == 0 then -- first press, expand and ensure enabled
                vim.diagnostic.config({ virtual_lines = true, virtual_text = false })
                vim.diagnostic.enable(0)
              elseif lsp_display == 1 then -- second press, disable completely
                vim.diagnostic.disable(0)
              elseif lsp_display == 2 then -- third press, cycle to default display
                vim.diagnostic.config({ virtual_lines = false, virtual_text = true })
                vim.diagnostic.enable(0)
              end
              lsp_display = (lsp_display + 1) % 3
            end,
            { desc = 'set lsp diagnostics' }
          },
          { 's',
            function()
              if vim.o.spell == true then
                vim.o.spell = false
              else
                vim.o.spell = true
              end
            end,
            { desc = 'set spell' }
          },
          { 'c',
            function()
              if vim.o.cursorline == true then
                vim.o.cursorline = false
                vim.o.cursorcolumn = false
              else
                vim.o.cursorline = true
                vim.o.cursorcolumn = true
              end
            end,
            { desc = 'draw crosshair' }
          },
          {
            'q',
            nil,
            { exit = true, nowait = true, desc = false }
          },
          { '<Esc>',
            nil,
            { exit = true, nowait = true, desc = false }
          },
        }
      })
    end
  })

  use({ -- beautify folds
    'anuvyklack/pretty-fold.nvim',
    config = function()
      require('pretty-fold').setup({})
    end
  })

  use({ -- mini plugin suite
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup({}) -- better text objects
      require('mini.comment').setup({}) -- commenting
      require('mini.indentscope').setup({
        draw = {
          animation = require('mini.indentscope').gen_animation('none'),
        },
        symbol = 'ˑּ',
        options = {
          try_as_border = true,
        },
      })
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('indentscope_python', {}),
        pattern = 'python',
        callback = function()
          require('mini.indentscope').config.options.border = 'top'
        end,
      })
      require('mini.jump').setup({}) -- better f and t mappings
      vim.api.nvim_create_autocmd({'ColorScheme', 'VimEnter'}, {
        group = vim.api.nvim_create_augroup('MinijumpHighlight', {}),
        callback = function()
          vim.api.nvim_set_hl(0, 'MiniJump', { reverse = true })
        end
      })
      require('mini.pairs').setup({ -- autocomplete pairs
        mappings = {
          ['('] = { action = 'open', pair = '()', neigh_pattern = '[^\\]%s' },
          ['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\]%s' },
          ['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\]%s' },
          [')'] = { action = 'close', pair = '()', neigh_pattern = '[^\\]%s' },
          [']'] = { action = 'close', pair = '[]', neigh_pattern = '[^\\]%s' },
          ['}'] = { action = 'close', pair = '{}', neigh_pattern = '[^\\]%s' },
          ['"'] = { action = 'closeopen', pair = '""', neigh_pattern = '[%s({[][^%a%d]'},
          ['\''] = { action = 'closeopen', pair = '\'\'', neigh_pattern = '[%s({[][^%a%d]'},
          ['`'] = { action = 'closeopen', pair = '``', neigh_pattern = '[%s({[][^%a%d]'},
        },
      })
      require('mini.surround').setup({ search_method = 'cover_or_next' }) -- change surroundings
      require('mini.trailspace').setup({}) -- highlight and remove trailing spaces
      vim.api.nvim_create_autocmd({'ColorScheme', 'VimEnter'}, {
        group = vim.api.nvim_create_augroup('MinitrailspaceHighlight', {}),
        callback = function()
          vim.api.nvim_set_hl(0, 'MiniTrailspace', { undercurl = true, sp = 'red' })
        end
      })
      vim.keymap.set('n', '<leader>w', require('mini.trailspace').trim, { desc = 'trim trailing whitespace' })
    end
  })

  use({ -- alternate ui elements
    'folke/noice.nvim',
    event = 'VimEnter',
    require = 'nvim-telescope/telescope.nvim',
    config = function()
      require('noice').setup()
      require('telescope').load_extension('noice')
      vim.keymap.set('n', '<leader>fm', require('telescope').extensions.noice.noice, { desc = 'telescope noice messages' })
    end,
    requires = {
      -- if you lazy-load any plugin below, make sure to add proper `module='...'` entries
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    }
  })

  use({ -- visual help for mappings
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
      require('which-key').register({
        g = { 'git hydra' },
        d = { 'debugger hydra' },
        o = { 'options hydra' },
      }, { prefix = '<leader>' })
    end
  })

  use({ -- yankring
    'gbprod/yanky.nvim',
    config = function()
      require('yanky').setup({})
      vim.keymap.set({'n','x'}, 'p', '<Plug>(YankyPutAfter)')
      vim.keymap.set({'n','x'}, 'P', '<Plug>(YankyPutBefore)')
      vim.keymap.set({'n','x'}, 'gp', '<Plug>(YankyGPutAfter)')
      vim.keymap.set({'n','x'}, 'gP', '<Plug>(YankyGPutBefore)')
      vim.keymap.set('n', '<c-n>', '<Plug>(YankyCycleForward)')
      vim.keymap.set('n', '<c-p>', '<Plug>(YankyCycleBackward)')
      vim.api.nvim_create_autocmd({'ColorScheme', 'VimEnter'}, {
        group = vim.api.nvim_create_augroup('YankyHighlight', {}),
        callback = function()
          vim.api.nvim_set_hl(0, 'YankyPut', { link = 'IncSearch' })
          vim.api.nvim_set_hl(0, 'YankyYanked', { link = 'IncSearch' })
        end
      })
    end
  })

  use({ -- better movement
    'ggandor/leap.nvim',
    config = function()
      vim.keymap.set({'n'}, 'S', function()
        require('leap').leap({ target_windows = { vim.fn.win_getid() } })
      end)
      vim.keymap.set({'v', 'o'}, 'S', function()
        require('leap').leap({ target_windows = { vim.fn.win_getid() }, offset = -1 })
      end)
    end
  })

  use({ -- completion engine
    'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
    },
    config = function()
      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
      end
      local cmp = require('cmp')
      cmp.setup({
        mapping = {
          ['<Tab>'] = function(fallback)
            if not cmp.select_next_item() then
              if vim.bo.buftype ~= 'prompt' and has_words_before() then
                cmp.complete()
              else
                fallback()
              end
            end
          end,
          ['<S-Tab>'] = function(fallback)
            if not cmp.select_prev_item() then
              if vim.bo.buftype ~= 'prompt' and has_words_before() then
                cmp.complete()
              else
                fallback()
              end
            end
          end,
        },
        sources = cmp.config.sources(
          {
            { name = 'nvim_lsp' },
            { name = 'buffer' },
          },
          {
            { name = 'buffer' },
          }
        ),
        enabled = function()
          local context = require('cmp.config.context')
          if vim.api.nvim_get_mode().mode == 'c' then
            return true
          else
            return not context.in_treesitter_capture('comment')
              and not context.in_syntax_group('Comment')
          end
        end,
      })
    end
  })

  use({ -- go test coverage
    'ja-he/nvim-goc.lua',
    branch = 'fix-deprecated-hi-link',
    ft = 'go',
    config = function()
      require('nvim-goc').setup({ verticalSplit = false })
      vim.keymap.set('n', '<leader>tc',
        function()
          if GocCoverageOn == true then
            require('nvim-goc').ClearCoverage()
            GocCoverageOn = false
          else
            require('nvim-goc').Coverage()
            GocCoverageOn = true
          end
        end, { desc = 'test: show coverage' })
      vim.keymap.set('n', '<leader>a', require('nvim-goc').Alternate, { desc = 'goto or create test file' })
    end
  })

  use({ -- smooth scrolling
    'karb94/neoscroll.nvim',
    config = function()
      require('neoscroll').setup({})
    end
  })

  use({ -- debug module for go
    'leoluz/nvim-dap-go',
    requires = { 'mfussenegger/nvim-dap' },
    ft = 'go',
    key = {
      { 'n', '<leader>d', 'debug' }
    },
    config = function()
      require('dap-go').setup()
      vim.keymap.set('n', '<leader>td', require('dap-go').debug_test, { desc = 'test: start debugging closest' })
    end
  })

  use({ -- git status in sign column
    'lewis6991/gitsigns.nvim',
    require = { 'anuvyklack/hydra.nvim' },
    config = function()
      require('gitsigns').setup()
      local hint = [[
 _s_: stage hunk  _S_: stage buffer     _u_: undo last stage  _U_: unstage buffer
 _J_: next hunk   _K_: previous hunk    _p_: preview hunk     _C_: change base
 _b_: blame       _B_: blame with diff  _d_: toggle deleted   _w_: toggle word diff         ]]
      local Hydra = require('hydra')
      Hydra({
        name = 'Git',
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
        mode = { 'n', 'x' },
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
          { 'C', function() require('gitsigns').change_base(vim.fn.input('Branch: ')) end,
            { desc = 'change base branch' } },
          { 'q', nil, { exit = true, nowait = true, desc = 'exit' } },
          { '<Esc>', nil, { exit = true, nowait = true, desc = false } }
        }
      })
    end
  })

  use({ -- visualize undo tree
    'mbbill/undotree',
    keys = {
      { 'n', '<leader>u', 'undo tree' }
    },
    config = function()
      vim.keymap.set('n', '<leader>u', function()
        vim.cmd('UndotreeToggle')
        vim.cmd('UndotreeFocus')
      end, { desc = 'toggle undo tree' })
    end
  })

  use({ -- debug adapter
    'mfussenegger/nvim-dap',
    require = { 'anuvyklack/hydra.nvim' },
    key = {
      { 'n', '<leader>d', 'debug' }
    },
    config = function()
      vim.keymap.set('n', '<leader>b', require('dap').toggle_breakpoint, { desc = 'debug: toggle breakpoint' })
      vim.keymap.set('n', '<leader>B',
        function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end,
        { desc = 'debug: set conditional breakpoint' })
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('on_dap_repl', {}),
        pattern = 'dap-repl',
        callback = function()
          vim.cmd('startinsert')
        end,
      })
      local Hydra = require('hydra')
      local hint = [[
 _c_: continue      _s_: step over    _fu_: frame up         _e_: evaluate at cursor
 _C_: run to cursor _i_: step into    _fd_: frame down       _E_: evaluate expression
 _r_: open repl     _o_: step out     _b_: toggle breakpoint _B_: set conditional breakpoint         ]]
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
        mode = { 'n', 'x' },
        body = '<leader>d',
        heads = {
          { 'c',
            function()
              require('dap').continue()
            end,
            { desc = 'continue or start' }
          },
          { 'C',
            function()
              require('dap').run_to_cursor()
            end,
            { desc = 'run to cursor' }
          },
          { 's',
            function()
              require('dap').step_over()
            end,
            { desc = 'step over' }
          },
          { 'i',
            function()
              require('dap').step_into()
            end,
            { desc = 'step into' }
          },
          { 'o',
            function()
              require('dap').step_out()
            end,
            { desc = 'step out' }
          },
          { 'fd',
            function()
              require('dap').down()
            end,
            { desc = 'frame down' }
          },
          { 'fu',
            function()
              require('dap').up()
            end,
            { desc = 'frame up' }
          },
          { 'e',
            function()
              require('dap.ui.widgets').preview()
            end,
            { desc = 'evaluate value under cursor' }
          },
          { 'E',
            function()
              require('dap.ui.widgets').preview(vim.fn.input('Expression: '))
            end,
            { desc = 'evaluate given expression' }
          },
          { 'b',
            function()
              require('dap').toggle_breakpoint()
            end,
            { desc = 'toggle breakpoint' }
          },
          { 'B',
            function()
              require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
            end,
            { desc = 'set conditional breakpoint' }
          },
          { 'r',
            function()
              require('dap').repl.toggle()
              vim.cmd('wincmd j')
            end,
            { desc = 'debug: repl' }
          },
          { 'q',
            function()
              require('dap').repl.close()
            end,
            { desc = 'quit', exit = true }
          },
          { '<Esc>',
            function()
              require('dap').repl.close()
            end,
            { desc = false, exit = true }
          },
          { 'Q',
            function()
              require('dap').repl.close()
              require('dap.breakpoints').clear()
              require('dapui').close()
            end,
            { desc = 'quit and reset', exit = true }
          },
        }
      })
    end
  })

  use({ -- better incremental selection compared to stock treesitter
    'mfussenegger/nvim-treehopper',
    config = function()
      vim.keymap.set({ 'n', 'o', 'v' }, '<cr>', require('tsht').nodes, { desc = 'select scope' })
    end
  })

  use({ -- status and tabline
    'nvim-lualine/lualine.nvim',
    config = function()
      vim.api.nvim_create_autocmd({ 'RecordingEnter', 'RecordingLeave' }, {
        group = vim.api.nvim_create_augroup('refresh_recording_indicator', {}),
        callback = function()
          require('lualine').refresh({ place = { 'statusline' }, })
        end,
      })
      require('lualine').setup({
        options = {
          component_separators = { left = '', right = ''},
          section_separators = { left = '', right = '' },
          globalstatus = true,
          icons_enabled = false,
        },
        sections = {
          lualine_x = {
            { 'macro-recording',
              fmt = function()
                local recording_register = vim.fn.reg_recording()
                if recording_register == '' then
                  return ''
                else
                  return 'recording @' .. recording_register
                end
              end,
              color = { fg = 'orange' },
            },
            'encoding',
            'filetype',
          },
        },
        tabline = {  -- TODO: replace with winbar when it does not flicker on first load
          lualine_c = {
            {
              'buffers',
              buffers_color = {
                active = 'Search',
              },
              symbols = {
                alternate_file = '',
              }
            },
          },
          lualine_x = {
            { 'filename', path = 1 },
          },
        },
      })
    end
  })

  use({ -- fuzzy picker
    'nvim-telescope/telescope.nvim',
    requires = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope-file-browser.nvim' },
    config = function()
      require('telescope').setup {
        defaults = {
          mappings = {
            i = {
              ['<C-j>'] = require('telescope.actions').move_selection_next,
              ['<C-k>'] = require('telescope.actions').move_selection_previous,
              ['<Esc>'] = require('telescope.actions').close,
            },
          }
        },
        extensions = {
          file_browser = {
            theme = 'ivy',
            hijack_netrw = true,
          },
        },
        pickers = {
          colorscheme = {
            enable_preview = true,
          }
        },
      }
      require('telescope').load_extension('file_browser')
      vim.keymap.set('n', '<leader>ft', require('telescope.builtin').builtin, { desc = 'telescope pick telescope' })
      vim.keymap.set('n', '<leader>fr', require('telescope.builtin').lsp_references, { desc = 'telescope pick lsp references' })
      vim.keymap.set('n', '<leader>fi', require('telescope.builtin').lsp_implementations, { desc = 'telescope pick lsp implementations' })
      vim.keymap.set('n', '<leader>fc', require('telescope.builtin').colorscheme, { desc = 'telescope pick colorscheme' })
      vim.keymap.set('n', '<leader>fs', require('telescope.builtin').lsp_document_symbols, { desc = 'telescope pick lsp symbols' })
      vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, { desc = 'telescope grep in project' })
      vim.keymap.set('n', '<leader>fb', require('telescope.builtin').buffers, { desc = 'telescope pick buffer' })
      vim.keymap.set('n', '<leader>ff', require('telescope').extensions.file_browser.file_browser, { desc = 'telescope browse files' })
      vim.keymap.set('n', '-', require('telescope').extensions.file_browser.file_browser, { desc = 'telescope browse files' })
    end
  })

  use({ -- treesitter itself, with fancy text objects
    'nvim-treesitter/nvim-treesitter',
    requires = { 'nvim-treesitter/nvim-treesitter-textobjects' },
    run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = 'all',
        auto_install = true,
        highlight = {
          enable = true,
        },
        indent = {
          enable = true
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
              ['ib'] = '@block.inner',
              ['al'] = '@loop.outer',
              ['il'] = '@loop.inner',
              ['is'] = '@statement.inner',
              ['as'] = '@statement.outer',
              ['ad'] = '@comment.outer',
              ['am'] = '@call.outer',
              ['im'] = '@call.inner'
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              [']]'] = '@function.outer',
            },
            goto_next_end = {
              [']['] = '@function.outer',
            },
            goto_previous_start = {
              ['[['] = '@function.outer',
            },
            goto_previous_end = {
              ['[]'] = '@function.outer',
            },
          },
        },
      })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufAdd', 'BufNew', 'BufNewFile', 'BufWinEnter' }, {
        group = vim.api.nvim_create_augroup('TS_FOLD_WORKAROUND', {}),
        callback = function()
          vim.opt.foldmethod = 'expr'
          vim.opt.foldexpr   = 'nvim_treesitter#foldexpr()'
        end
      })
    end
  })

  use({ -- colorscheme
    'rebelot/kanagawa.nvim',
    config = function()
      require('kanagawa').setup({
        dimInactive = true,
        globalStatus = true,
        commentStyle = { italic = false },
        keywordStyle = { italic = false},
        variablebuiltinStyle = { italic = false},
      })
      vim.cmd('colorscheme kanagawa')
    end
  })

  use({ -- highlight references, ideally with info from lsp
    'RRethy/vim-illuminate',
    config = function()
      require('illuminate').configure({
        providers = {
          'treesitter',
          'regex',
        },
        modes_allowlist = { 'n', 'i' },
        filetypes_denylist = {
          'terminal',
        },
      })
      vim.keymap.set('n', '<leader>i', require('illuminate').toggle, { desc = 'illuminate: toggle' })
      vim.keymap.set('n', ']r', function()
        for _ = 1, vim.v.count1 do
          require('illuminate').goto_next_reference()
        end
      end, { desc = 'illuminate: jump to next reference' })
      vim.keymap.set('n', '[r', function()
        for _ = 1, vim.v.count1 do
          require('illuminate').goto_prev_reference()
        end
      end, { desc = 'illuminate: jump to previous reference' })
      vim.api.nvim_create_autocmd({'ColorScheme', 'VimEnter'}, {
        group = vim.api.nvim_create_augroup('IlluminateHighlight', {}),
        callback = function()
          vim.api.nvim_set_hl(0, 'IlluminatedWordRead', { link = 'Visual' })
          vim.api.nvim_set_hl(0, 'IlluminatedWordText', { link = 'Visual' })
          vim.api.nvim_set_hl(0, 'IlluminatedWordWrite', { fg = 'orange' })
        end
      })
    end,
  })

  use({ -- never bother with indent, editorconfig and modeline support
    'tpope/vim-sleuth',
  })

  use({ -- self-manage
    'wbthomason/packer.nvim',
    config = function()
      -- make packer sync automatically after editing this file
      vim.api.nvim_create_autocmd('BufWritePost', {
        group = vim.api.nvim_create_augroup('on_save_nvim_plugins', {}),
        pattern = 'plugins.lua',
        callback = function()
          package.loaded['plugins'] = nil
          require('plugins')
          require('packer').sync()
        end
      })
    end
  })

  use({ -- better display of diagnostics
    'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
    config = function()
      require('lsp_lines').setup()
      vim.diagnostic.config({
        virtual_text = true,
        virtual_lines = false,
      })
    end,
  })

  if PackerBootstrap then
    require('packer').sync()
  end
end
)
