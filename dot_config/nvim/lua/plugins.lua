local function override_highlight(callback)
  callback()
  vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = callback,
  })
end

return {
  {
    "Eandrju/cellular-automaton.nvim",
    keys = "<leader>fml",
    command = "CellularAutomaton",
    config = function()
      vim.keymap.set("n", "<leader>fml", "<cmd>CellularAutomaton make_it_rain<cr>")
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    dependencies = "anuvyklack/hydra.nvim",
    config = function()
      require("gitsigns").setup()
      require("hydra")({
        name = "Git",
        hint = [[
_s_: stage hunk  _S_: stage buffer     _u_: undo last stage  _U_: unstage buffer
_J_: next hunk   _K_: previous hunk    _p_: preview hunk     _C_: change base
_b_: blame       _B_: blame with diff  _d_: toggle deleted   _w_: toggle word diff         ]],
        config = {
          color = "pink",
          invoke_on_body = true,
          hint = {
            type = "window",
            border = "single",
            position = "bottom",
          },
          on_enter = function()
            vim.cmd("mkview")
            vim.cmd("silent! %foldopen!")
            vim.bo.modifiable = false
            require("gitsigns").toggle_linehl(true)
          end,
          on_exit = function()
            local cursor_pos = vim.api.nvim_win_get_cursor(0)
            vim.cmd("loadview")
            vim.api.nvim_win_set_cursor(0, cursor_pos)
            require("gitsigns").toggle_linehl(false)
            require("gitsigns").toggle_deleted(false)
          end,
        },
        mode = { "n", "x" },
        body = "<leader>g",
        heads = {
          {
            "J",
            function()
              if vim.wo.diff then
                return "]c"
              end
              vim.schedule(function()
                require("gitsigns").next_hunk()
              end)
              return "<Ignore>"
            end,
            { expr = true, desc = "next hunk" },
          },
          {
            "K",
            function()
              if vim.wo.diff then
                return "[c"
              end
              vim.schedule(function()
                require("gitsigns").prev_hunk()
              end)
              return "<Ignore>"
            end,
            { expr = true, desc = "prev hunk" },
          },
          { "s", require("gitsigns").stage_hunk, { silent = true, nowait = true, desc = "stage hunk" } },
          { "S", require("gitsigns").stage_buffer, { desc = "stage buffer" } },
          { "u", require("gitsigns").undo_stage_hunk, { desc = "undo last stage" } },
          { "U", require("gitsigns").reset_buffer_index, { silent = true, nowait = true, desc = "unstage all" } },
          { "p", require("gitsigns").preview_hunk, { desc = "preview hunk" } },
          { "d", require("gitsigns").toggle_deleted, { nowait = true, desc = "toggle deleted" } },
          { "w", require("gitsigns").toggle_word_diff, { nowait = true, desc = "toggle word diff" } },
          { "b", require("gitsigns").blame_line, { desc = "blame" } },
          {
            "B",
            function()
              require("gitsigns").blame_line({ full = true })
            end,
            { desc = "blame show full" },
          },
          {
            "C",
            function()
              require("gitsigns").change_base(vim.fn.input("Branch: "))
            end,
            { desc = "change base branch" },
          },
          { "q", nil, { exit = true, nowait = true, desc = "exit" } },
          { "<Esc>", nil, { exit = true, nowait = true, desc = false } },
        },
      })
    end,
  },

  {
    "anuvyklack/hydra.nvim",
    event = "VeryLazy",
    config = function()
      require("hydra")({
        name = "Options",
        hint = [[
Options
_v_ %{ve} set virtualedit
_b_ %{bg} set background
_l_ %{list} set list
_w_ %{wrap} set wrap
_s_ %{spell} set spell
_c_ %{cux} draw crosshair
_n_ %{nu} set number
_r_ %{relativenumber} set relativenumber
_i_ %{indentscope} set indentscope
_I_ %{illuminate} set illuminate
_L_ %{lsp} set lsp diagnostic      ]],
        config = {
          color = "red",
          invoke_on_body = true,
          hint = {
            border = "rounded",
            position = "middle",
            funcs = {
              bg = function()
                if vim.o.background == "dark" then
                  return "[d]"
                else
                  return "[l]"
                end
              end,
              indentscope = function()
                if vim.g.miniindentscope_disable then
                  return "[ ]"
                else
                  return "[x]"
                end
              end,
              illuminate = function()
                if vim.g.illuminate_disable then
                  return "[ ]"
                else
                  return "[x]"
                end
              end,
              lsp = function()
                if LspDisplay == nil then
                  LspDisplay = 0
                end
                if LspDisplay == 0 then
                  return "[x]"
                elseif LspDisplay == 1 then
                  return "[v]"
                elseif LspDisplay == 2 then
                  return "[ ]"
                end
              end,
            },
          },
        },
        mode = { "n", "x" },
        body = "<leader>o",
        heads = {
          {
            "n",
            function()
              if vim.o.number == true then
                vim.o.number = false
              else
                vim.o.number = true
              end
            end,
            { desc = "set number" },
          },
          {
            "b",
            function()
              if vim.o.background == "dark" then
                vim.o.background = "light"
              else
                vim.o.background = "dark"
              end
            end,
            { desc = "set background" },
          },
          {
            "r",
            function()
              if vim.o.relativenumber == true then
                vim.o.relativenumber = false
              else
                vim.o.relativenumber = true
              end
            end,
            { desc = "set relativenumber" },
          },
          {
            "i",
            function()
              if vim.g.miniindentscope_disable == true then
                vim.g.miniindentscope_disable = false
              else
                vim.g.miniindentscope_disable = true
              end
            end,
            { desc = "set indentscope" },
          },
          {
            "I",
            function()
              require("illuminate").toggle()
              vim.g.illuminate_disable = not vim.g.illuminate_disable
            end,
            { desc = "set illuminate" },
          },
          {
            "v",
            function()
              if vim.o.virtualedit == "all" then
                vim.o.virtualedit = "block"
              else
                vim.o.virtualedit = "all"
              end
            end,
            { desc = "set virtualedit" },
          },
          {
            "l",
            function()
              if vim.o.list == true then
                vim.o.list = false
              else
                vim.o.list = true
              end
            end,
            { desc = "set list" },
          },
          {
            "w",
            function()
              if vim.o.wrap == true then
                vim.o.wrap = false
              else
                vim.o.wrap = true
              end
            end,
            { desc = "set wrap" },
          },
          {
            "L",
            function()
              if LspDisplay == 0 then -- first press, expand and ensure enabled
                vim.diagnostic.config({ virtual_lines = true, virtual_text = false })
                vim.diagnostic.enable(0)
              elseif LspDisplay == 1 then -- second press, disable completely
                vim.diagnostic.disable(0)
              elseif LspDisplay == 2 then -- third press, cycle to default display
                vim.diagnostic.config({ virtual_lines = false, virtual_text = true })
                vim.diagnostic.enable(0)
              end
              LspDisplay = (LspDisplay + 1) % 3
            end,
            { desc = "set lsp diagnostics" },
          },
          {
            "s",
            function()
              if vim.o.spell == true then
                vim.o.spell = false
              else
                vim.o.spell = true
              end
            end,
            { desc = "set spell" },
          },
          {
            "c",
            function()
              if vim.o.cursorline == true then
                vim.o.cursorline = false
                vim.o.cursorcolumn = false
              else
                vim.o.cursorline = true
                vim.o.cursorcolumn = true
              end
            end,
            { desc = "draw crosshair" },
          },
          { "q", nil, { exit = true, nowait = true, desc = false } },
          { "<Esc>", nil, { exit = true, nowait = true, desc = false } },
        },
      })
    end,
  },

  {
    "rebelot/kanagawa.nvim",
    config = function()
      local default_colors = require("kanagawa.colors").setup()
      require("kanagawa").setup({
        dimInactive = true,
        globalStatus = true,
        commentStyle = { italic = false },
        keywordStyle = { italic = false },
        variablebuiltinStyle = { italic = false },
        overrides = {
          -- fix Noice's cmdline borders
          DiagnosticInfo = { fg = default_colors.diag.info, bg = "bg" },
          DiagnosticWarn = { fg = default_colors.diag.warning, bg = "bg" },
          -- invisible separators
          WinSeparator = { fg = default_colors.bg_dim, bg = default_colors.bg_dim },
        },
      })
      vim.cmd("colorscheme kanagawa")
    end,
  },

  {
    "ggandor/flit.nvim",
    keys = { "f", "F", "t", "T" },
    dependencies = { "ggandor/flit.nvim" },
    config = function()
      require("flit").setup()
    end,
  },

  {
    "ggandor/leap.nvim",
    keys = { "S" },
    config = function()
      vim.keymap.set({ "n" }, "S", function()
        require("leap").leap({ target_windows = { vim.fn.win_getid() } })
      end)
      vim.keymap.set({ "v", "o" }, "S", function()
        require("leap").leap({ target_windows = { vim.fn.win_getid() }, offset = -1 })
      end)
      override_highlight(function()
        vim.api.nvim_set_hl(0, "LeapBackdrop", { link = "Comment" })
        vim.api.nvim_set_hl(0, "LeapMatch", {
          fg = vim.o.background == "dark" and "white" or "black",
          bold = true,
          nocombine = true,
        })
      end)
      require("leap").opts.highlight_unlabeled_phase_one_targets = true
    end,
  },

  {
    "whynothugo/lsp_lines.nvim",
    event = "LspAttach",
    config = function()
      vim.diagnostic.config({
        virtual_text = true,
        virtual_lines = false,
      })
      require("lsp_lines").setup()
    end,
    url = "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
  },

  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = {
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
          icons_enabled = false,
        },
        sections = {
          lualine_c = {
            { "filename", path = 1 },
          },
          lualine_x = {
            {
              "macro-recording",
              fmt = function()
                local recording_register = vim.fn.reg_recording()
                if recording_register == "" then
                  return ""
                else
                  return "recording @" .. recording_register
                end
              end,
              color = { fg = "orange" },
            },
            "encoding",
            "filetype",
          },
        },
        -- TODO: make full width available for tabline
        -- TODO: replace tabline with winbar eventually, right now it flickers
        tabline = {
          lualine_c = {
            {
              "buffers",
              buffers_color = {
                active = "Search",
              },
              symbols = {
                alternate_file = "",
              },
            },
          },
        },
      })
      vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
        group = vim.api.nvim_create_augroup("refresh_recording_indicator", {}),
        callback = function()
          require("lualine").refresh({ place = { "statusline" } })
        end,
      })
    end,
  },

  {
    "phaazon/mind.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("mind").setup()
    end,
  },

  {
    "echasnovski/mini.nvim",
    event = "VeryLazy",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", dependencies = { "nvim-treesitter/nvim-treesitter" } }, -- mini.ai
      { "JoosepAlviste/nvim-ts-context-commentstring" }, -- mini.comment
    },
    config = function()
      -- mini.ai
      local ai = require("mini.ai")
      ai.setup({
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }, {}),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
          F = ai.gen_spec.function_call(),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
        },
      })
      local map = function(text_obj, desc)
        for _, side in ipairs({ "left", "right" }) do
          for dir, d in pairs({ prev = "[", next = "]" }) do
            local lhs = d .. (side == "right" and text_obj:upper() or text_obj:lower())
            for _, mode in ipairs({ "n", "x", "o" }) do
              vim.keymap.set(mode, lhs, function()
                ai.move_cursor(side, "a", text_obj, { search_method = dir })
              end, {
                desc = dir .. " " .. desc,
              })
            end
          end
        end
      end
      map("f", "function")
      map("c", "class")
      -- mini.animate
      require("mini.animate").setup({})
      -- mini.bufremove
      vim.keymap.set("n", "<leader><tab>", function()
        require("mini.bufremove").delete(0, false)
      end)
      vim.keymap.set("n", "<leader><S-tab>", function()
        require("mini.bufremove").delete(0, true)
      end)
      --mini.comment
      require("mini.comment").setup({
        hooks = {
          pre = function()
            require("ts_context_commentstring.internal").update_commentstring({})
          end,
        },
      })
      -- mini.indentscope
      require("mini.indentscope").setup({
        draw = {
          animation = require("mini.indentscope").gen_animation.none(),
        },
        symbol = "·",
        options = {
          try_as_border = true,
        },
      })
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("indentscope_python", {}),
        pattern = "python",
        callback = function()
          require("mini.indentscope").config.options.border = "top"
        end,
      })
      -- mini.surround
      require("mini.surround").setup({ search_method = "cover_or_next" })
      -- mini.trailspace
      require("mini.trailspace").setup({})
      vim.keymap.set("n", "<leader>w", require("mini.trailspace").trim, { desc = "trim trailing whitespace" })
    end,
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    config = function()
      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
      })
    end,
  },

  {
    "jose-elias-alvarez/null-ls.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim", "williamboman/mason.nvim" },
    init = function()
      local mason = require("mason-core.package")
      local reg = require("mason-registry")
      for _, pkg_name in ipairs({ "stylua", "vale", "yamllint" }) do
        local pkg = reg.get_package(pkg_name)
        if pkg:is_installed() == false then
          mason.install(pkg)
        end
      end
    end,
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          -- lua
          null_ls.builtins.formatting.stylua,
          -- markdown and prose
          null_ls.builtins.diagnostics.vale,
          null_ls.builtins.hover.dictionary,
          -- yaml
          null_ls.builtins.diagnostics.yamllint,
        },
      })
      -- autoformat lua on save
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "lua",
        callback = function()
          -- automatic format on save
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("LspFormat", { clear = true }),
            callback = function()
              vim.lsp.buf.format({ async = false }, 3000)
            end,
          })
        end,
      })
      -- start without diagnostics on markdown
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          vim.diagnostic.disable(0)
          LspDisplay = 2
        end,
      })
    end,
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "windwp/nvim-autopairs",
    },
    config = function()
      require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end
      local cmp = require("cmp")
      cmp.setup({
        preselect = cmp.PreselectMode.None,
        mapping = {
          ["<Tab>"] = function(fallback)
            if not cmp.select_next_item() then
              if vim.bo.buftype ~= "prompt" and has_words_before() then
                cmp.complete()
              else
                fallback()
              end
            end
          end,
          ["<S-Tab>"] = function(fallback)
            if not cmp.select_prev_item() then
              if vim.bo.buftype ~= "prompt" and has_words_before() then
                cmp.complete()
              else
                fallback()
              end
            end
          end,
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "buffer" },
        }, {
          { name = "buffer" },
        }),
        sorting = {
          comparators = {
            cmp.config.compare.locality,
            cmp.config.compare.recently_used,
            cmp.config.compare.score,
            cmp.config.compare.offset,
            cmp.config.compare.order,
          },
        },
        enabled = function()
          local context = require("cmp.config.context")
          if vim.api.nvim_get_mode().mode == "c" then
            return true
          else
            return not context.in_treesitter_capture("comment") and not context.in_syntax_group("Comment")
          end
        end,
      })
      require("cmp").event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
    end,
  },

  {
    "mfussenegger/nvim-dap",
    event = "VeryLazy",
    dependencies = "anuvyklack/hydra.nvim",
    config = function()
      vim.keymap.set("n", "<leader>b", require("dap").toggle_breakpoint, { desc = "debug: toggle breakpoint" })
      vim.keymap.set("n", "<leader>B", function()
        require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "debug: set conditional breakpoint" })
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("on_dap_repl", {}),
        pattern = "dap-repl",
        callback = function()
          vim.cmd("startinsert")
        end,
      })
      require("hydra")({
        name = "Debug",
        hint = [[
_t_: debug test    _c_: continue     _s_: step over      _fu_: frame up      _fd_: frame down
_C_: run to cursor _i_: step into    _e_: evaluate at cursor  _E_: evaluate expression
_r_: open repl     _o_: step out     _b_: toggle breakpoint   _B_: set conditional breakpoint         ]],
        config = {
          color = "pink",
          invoke_on_body = true,
          hint = {
            type = "window",
            border = "single",
            position = "bottom",
          },
        },
        mode = { "n", "x" },
        body = "<leader>d",
        heads = {
          {
            "t",
            function()
              require("dap-go").debug_test()
            end,
            { desc = "debug test" },
          },
          {
            "c",
            function()
              require("dap").continue()
            end,
            { desc = "continue" },
          },
          {
            "C",
            function()
              require("dap").run_to_cursor()
            end,
            { desc = "run to cursor" },
          },
          {
            "s",
            function()
              require("dap").step_over()
            end,
            { desc = "step over" },
          },
          {
            "i",
            function()
              require("dap").step_into()
            end,
            { desc = "step into" },
          },
          {
            "o",
            function()
              require("dap").step_out()
            end,
            { desc = "step out" },
          },
          {
            "fd",
            function()
              require("dap").down()
            end,
            { desc = "frame down" },
          },
          {
            "fu",
            function()
              require("dap").up()
            end,
            { desc = "frame up" },
          },
          {
            "e",
            function()
              require("dap.ui.widgets").preview()
            end,
            { desc = "evaluate value under cursor" },
          },
          {
            "E",
            function()
              require("dap.ui.widgets").preview(vim.fn.input("Expression: "))
            end,
            { desc = "evaluate given expression" },
          },
          {
            "b",
            function()
              require("dap").toggle_breakpoint()
            end,
            { desc = "toggle breakpoint" },
          },
          {
            "B",
            function()
              require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
            end,
            { desc = "set conditional breakpoint" },
          },
          {
            "r",
            function()
              require("dap").repl.toggle()
              vim.cmd("wincmd j")
            end,
            { desc = "debug: repl" },
          },
          {
            "q",
            function()
              require("dap").repl.close()
              require("dap").terminate()
            end,
            { desc = "quit", exit = true },
          },
          {
            "<Esc>",
            function()
              require("dap").repl.close()
            end,
            { desc = false, exit = true },
          },
          {
            "Q",
            function()
              require("dap").repl.close()
              require("dap").terminate()
              require("dap.breakpoints").clear()
            end,
            { desc = "quit and reset", exit = true },
          },
        },
      })
    end,
  },

  {
    "leoluz/nvim-dap-go",
    ft = "go",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dap-go").setup()
      vim.keymap.set("n", "<leader>td", require("dap-go").debug_test, { desc = "test: start debugging closest" })
    end,
  },

  {
    "rafaelsq/nvim-goc.lua",
    ft = "go",
    config = function()
      require("nvim-goc").setup({ verticalSplit = false })
      vim.keymap.set("n", "<leader>tc", function()
        if GocCoverageOn == true then
          require("nvim-goc").ClearCoverage()
          GocCoverageOn = false
        else
          require("nvim-goc").Coverage()
          GocCoverageOn = true
        end
      end, { desc = "test: show coverage" })
      vim.keymap.set("n", "<leader>a", require("nvim-goc").Alternate, { desc = "goto or create test file" })
    end,
  },

  {
    "williamboman/mason.nvim",
    event = "VeryLazy",
    config = function()
      require("mason").setup()
      vim.keymap.set("n", "<leader>m", "<cmd>Mason<cr>", { desc = "Manage additional tools" })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
    config = function()
      local on_attach = function(_, bufnr)
        vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
          vim.lsp.buf.format()
        end, { desc = "Format current buffer with LSP" })
      end
      -- install servers using mason
      local servers = { "gopls", "sumneko_lua" }
      require("mason-lspconfig").setup({
        ensure_installed = servers,
      })
      -- configure lsp servers
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      -- gopls
      require("lspconfig").gopls.setup({
        on_attach = function(client, bufnr)
          -- automatic format on save
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("LspFormat", { clear = false }),
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ async = false }, 3000)
            end,
          })
          -- automatic organize imports on save
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("LspOrganizeImports", { clear = false }),
            buffer = bufnr,
            callback = function()
              local params = vim.lsp.util.make_range_params(nil, vim.lsp.util._get_offset_encoding())
              params.context = { only = { "source.organizeImports" } }
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
          on_attach(client, bufnr)
        end,
        capabilities = capabilities,
      })
      -- sumneko_lua
      local runtime_path = vim.split(package.path, ";")
      table.insert(runtime_path, "lua/?.lua")
      table.insert(runtime_path, "lua/?/init.lua")
      require("lspconfig").sumneko_lua.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",
              path = runtime_path,
            },
            diagnostics = {
              globals = { "vim" },
            },
            telemetry = { enable = false },
          },
        },
      })
    end,
  },

  {
    "mfussenegger/nvim-treehopper",
    keys = { "<leader><cr>" },
    config = function()
      vim.keymap.set({ "n", "o", "v" }, "<leader><cr>", require("tsht").nodes, { desc = "select scope" })
    end,
  },

  {
    "nvim-treesitter/playground",
    cmd = "TSPlaygroundToggle",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    event = "BufReadPost",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = "all",
        auto_install = false,
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        },
        playground = {
          enable = true,
          disable = {},
          updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
          persist_queries = true, -- Whether the query persists across vim sessions
          keybindings = {
            toggle_query_editor = "o",
            toggle_hl_groups = "i",
            toggle_injected_languages = "t",
            toggle_anonymous_nodes = "a",
            toggle_language_display = "I",
            focus_language = "f",
            unfocus_language = "F",
            update = "R",
            goto_node = "<cr>",
            show_help = "?",
          },
        },
      })
    end,
    build = function()
      require("nvim-treesitter.install").update()
    end,
  },

  {
    "samjwill/nvim-unception",
    event = "TermOpen",
    config = function() end,
  },

  {
    "kevinhwang91/rnvimr",
    event = "VeryLazy",
    config = function()
      vim.g.rnvimr_enable_ex = 1
      vim.g.rnvimr_vanilla = 1
      vim.g.rnvimr_enable_picker = 1
      vim.keymap.set("n", "-", ":RnvimrToggle<cr>", { desc = "browse files" })
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    -- event = "VeryLazy",
    keys = { "<leader>t", "<leader>/", "gd", "gr", "gI", "gO", "gC", "<leader>u", "<leader>n", "<leader>p" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "debugloop/telescope-undo.nvim",
      "folke/noice.nvim",
    },
    config = function()
      require("telescope").setup({
        defaults = {
          dynamic_preview_title = true,
          mappings = {
            i = {
              ["<c-j>"] = require("telescope.actions").move_selection_next,
              ["<c-k>"] = require("telescope.actions").move_selection_previous,
              ["<esc>"] = require("telescope.actions").close,
            },
          },
        },
        extensions = {
          undo = {
            side_by_side = true,
            layout_strategy = "vertical",
            layout_config = {
              preview_height = 0.8,
            },
          },
        },
      })
      vim.keymap.set("n", "<leader>f", require("telescope.builtin").builtin, { desc = "telescope pick telescope" })
      vim.keymap.set("n", "<leader>/", require("telescope.builtin").live_grep, { desc = "telescope grep in project" })
      -- lsp related pickers
      vim.keymap.set("n", "gd", require("telescope.builtin").lsp_definitions, { desc = "lsp: goto definition" })
      vim.keymap.set("n", "gr", require("telescope.builtin").lsp_references, { desc = "lsp: list references" })
      vim.keymap.set("n", "gI", require("telescope.builtin").lsp_implementations, { desc = "lsp: list impls" })
      vim.keymap.set("n", "gO", require("telescope.builtin").lsp_document_symbols, { desc = "lsp: outline symbols" })
      vim.keymap.set("n", "gC", require("telescope.builtin").lsp_incoming_calls, { desc = "lsp: list incoming calls" })
      -- telescope-undo.nvim
      require("telescope").load_extension("undo")
      vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>")
      -- noice.nvim
      require("telescope").load_extension("noice")
      vim.keymap.set("n", "<leader>n", require("telescope").extensions.noice.noice, { desc = "open messages" })
    end,
  },

  {
    "akinsho/toggleterm.nvim",
    keys = { "<c-cr", "<c-s-cr>" },
    config = function()
      require("toggleterm").setup({
        size = function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
          end
        end,
        shade_terminals = false,
        hide_numbers = false,
      })
      vim.keymap.set(
        { "n", "t" },
        "<c-cr>",
        "<cmd>exe v:count1 . 'ToggleTerm direction=horizontal'<cr>",
        { desc = "launch terminal" }
      )
      vim.keymap.set(
        { "n", "t" },
        "<c-s-cr>",
        "<cmd>exe v:count1 . 'ToggleTerm direction=vertical'<cr>",
        { desc = "launch terminal vertical" }
      )
      vim.api.nvim_create_autocmd("TermOpen", { -- special settings for terminal
        pattern = "*",
        callback = function()
          local opts = { buffer = 0 }
          vim.keymap.set("t", "<c-n>", [[<C-\><C-n>]], opts)
          vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
          vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
          vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
          vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
          vim.opt.relativenumber = false
        end,
      })
    end,
  },

  {
    "drybalka/tree-climber.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      local keyopts = { noremap = true, silent = true }
      vim.keymap.set({ "n", "v", "o" }, "<m-h>", function()
        require("tree-climber").goto_parent({ highlight = true })
      end, keyopts)
      vim.keymap.set({ "n", "v", "o" }, "<m-l>", function()
        require("tree-climber").goto_child({ highlight = true })
      end, keyopts)
      vim.keymap.set({ "n", "v", "o" }, "<m-j>", function()
        require("tree-climber").goto_next({ highlight = true })
      end, keyopts)
      vim.keymap.set({ "n", "v", "o" }, "<m-k>", function()
        require("tree-climber").goto_prev({ highlight = true })
      end, keyopts)
      vim.keymap.set("n", "<c-m-k>", require("tree-climber").swap_prev, keyopts)
      vim.keymap.set("n", "<c-m-j>", require("tree-climber").swap_next, keyopts)
      vim.keymap.set("n", "<c-m-h>", require("tree-climber").swap_prev, keyopts)
      vim.keymap.set("n", "<c-m-l>", require("tree-climber").swap_next, keyopts)
    end,
  },

  {
    "RRethy/vim-illuminate",
    event = "BufReadPost",
    config = function()
      require("illuminate").configure({
        providers = {
          "treesitter",
          "regex",
        },
        modes_allowlist = { "n", "i" },
        filetypes_denylist = {
          "terminal",
        },
      })
      vim.keymap.set("n", "<leader>i", require("illuminate").toggle, { desc = "illuminate: toggle" })
      vim.keymap.set("n", "]]", function()
        for _ = 1, vim.v.count1 do
          require("illuminate").goto_next_reference()
        end
      end, { desc = "illuminate: jump to next reference" })
      vim.keymap.set("n", "[[", function()
        for _ = 1, vim.v.count1 do
          require("illuminate").goto_prev_reference()
        end
      end, { desc = "illuminate: jump to previous reference" })
      override_highlight(function()
        vim.api.nvim_set_hl(0, "IlluminatedWordRead", { link = "Visual" })
        vim.api.nvim_set_hl(0, "IlluminatedWordText", { link = "Visual" })
        vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { fg = "orange" })
      end)
    end,
  },

  {
    "tpope/vim-sleuth",
    event = "BufReadPre",
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({
        plugins = {
          spelling = {
            enabled = true,
            suggestions = 20,
          },
        },
      })
      require("which-key").register({
        g = { "git hydra" },
        d = { "debugger hydra" },
        o = { "options hydra" },
      }, { prefix = "<leader>" })
    end,
  },

  {
    "gbprod/yanky.nvim",
    event = "VeryLazy",
    keys = { "<leader>p", "p", "P", "gp", "gP" }, -- no <C-n> or <C-p>, these are only pressed after paste
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      -- "reverse-load" this telescope extension, as it requires it's config here...
      require("yanky").setup({
        picker = {
          telescope = {
            mappings = {
              default = require("yanky.telescope.mapping").put("p"),
            },
          },
        },
      })
      require("telescope").load_extension("yank_history")
      vim.keymap.set(
        "n",
        "<leader>p",
        require("telescope").extensions.yank_history.yank_history,
        { desc = "paste from yank history" }
      )
      vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
      vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
      vim.keymap.set({ "n", "x" }, "gp", "<Plug>(YankyGPutBefore)")
      vim.keymap.set({ "n", "x" }, "gP", "<Plug>(YankyGPutAfter)")
      vim.keymap.set("n", "<c-n>", "<Plug>(YankyCycleForward)")
      vim.keymap.set("n", "<c-p>", "<Plug>(YankyCycleBackward)")
    end,
  },
}
