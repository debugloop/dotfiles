return {
  {
    src = "https://github.com/yorickpeterse/nvim-tree-pairs",
    config = function(_)
      require("tree-pairs").setup()
    end,
  },

  -- nvim-spider
  {
    defer = true,
    config = function(_)
      vim.keymap.set({ "n", "o", "x" }, "w", "<cmd>lua require('spider').motion('w')<cr>")
      vim.keymap.set({ "n", "o", "x" }, "e", "<cmd>lua require('spider').motion('e')<cr>")
      vim.keymap.set({ "n", "o", "x" }, "b", "<cmd>lua require('spider').motion('b')<cr>")
    end,
  },

  -- blink.cmp
  {
    event = { "InsertEnter", "CmdlineEnter" },
    config = function(opts)
      require("blink.cmp").setup(opts)
    end,
    opts = {
      keymap = {
        preset = "none",
        ["<tab>"] = {
          function(cmp)
            local has_words_before = function()
              local col = vim.api.nvim_win_get_cursor(0)[2]
              if col == 0 then
                return false
              end
              local line = vim.api.nvim_get_current_line()
              return line:sub(col, col):match("%s") == nil
            end
            if has_words_before() then
              return cmp.show_and_insert()
            end
          end,
          "fallback",
        },
        ["<enter>"] = { "select_and_accept", "fallback" },
        ["<left>"] = { "cancel", "fallback" },
        ["<down>"] = { "show_and_insert", "select_next", "fallback" },
        ["<up>"] = { "select_prev", "fallback" },
        ["<c-right>"] = { "show_and_insert", "select_and_accept", "fallback" },
        ["<right>"] = {
          function(cmp)
            local has_no_words_after = function()
              local col = vim.api.nvim_win_get_cursor(0)[2]
              local line = vim.api.nvim_get_current_line()
              if col == #line then
                return true
              end
              return line:sub(col + 1, col + 1):match("%s") ~= nil
            end
            if has_no_words_after() then
              return cmp.show_and_insert()
            end
          end,
          "select_and_accept",
          "fallback",
        },
      },
      cmdline = {
        enabled = true,
        keymap = {
          preset = "inherit",
          ["<enter>"] = { "fallback" },
          ["<down>"] = { "select_next", "fallback" },
        },
      },
      completion = {
        accept = {
          auto_brackets = { enabled = false },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 50,
        },
        ghost_text = {
          enabled = true,
          show_without_selection = true,
        },
        list = {
          selection = {
            preselect = false,
            auto_insert = true,
          },
        },
        menu = {
          auto_show = false,
          draw = {
            treesitter = { "lsp" },
            components = {
              kind_icon = {
                ellipsis = false,
                text = function(ctx)
                  local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
                  return kind_icon
                end,
                highlight = function(ctx)
                  local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                  return hl
                end,
              },
            },
          },
          max_height = 16,
          scrollbar = false,
        },
        trigger = {
          show_in_snippet = false,
          show_on_insert_on_trigger_character = false,
        },
      },
      signature = {
        enabled = true,
        trigger = { show_on_insert = true },
        window = { direction_priority = { "s", "n" } },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "lazydev" },
        providers = {
          lsp = {
            fallbacks = { "lazydev" },
            score_offset = 20,
          },
          lazydev = { name = "LazyDev", module = "lazydev.integrations.blink" },
          snippets = {
            enabled = function(ctx)
              if ctx == nil then
                return true
              end
              return ctx.trigger.kind ~= vim.lsp.protocol.CompletionTriggerKind.TriggerCharacter
            end,
          },
        },
      },
    },
  },

  -- conform.nvim
  {
    defer = true,
    config = function(opts)
      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, {
        desc = "Disable autoformat-on-save",
        bang = true,
      })
      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, {
        desc = "Re-enable autoformat-on-save",
      })
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
      require("conform").setup(opts)
    end,
    opts = {
      formatters_by_ft = {
        css = { "prettier" },
        go = { "golangci-lint", "gofumpt", "goimports", "goimports-reviser" },
        html = { "prettier" },
        http = { "kulala-fmt" },
        javascript = { "prettier" },
        lua = { "stylua" },
        nix = { "alejandra" },
        rust = { "rustfmt" },
        templ = { "templ" },
        ["*"] = function(bufnr)
          if vim.fn.getbufvar(bufnr, "&filetype") == "terraform" then
            return {}
          end
          return { "trim_whitespace" }
        end,
      },
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return {
          lsp_fallback = true,
          timeout_ms = 5000,
        }
      end,
      formatters = {
        prettier = {
          prepend_args = { "--tab-width", "4" },
        },
      },
    },
  },

  -- kanagawa.nvim
  {
    config = function(opts)
      require("kanagawa").setup(opts)
      require("kanagawa").load("wave")
    end,
    opts = {
      theme = "wave",
      dimInactive = true,
      commentStyle = { italic = false },
      keywordStyle = { italic = false },
      variablebuiltinStyle = { italic = false },
      overrides = function(colors)
        local theme = colors.theme
        local makeDiagnosticColor = function(color)
          local c = require("kanagawa.lib.color")
          return { fg = color, bg = c(color):blend(theme.ui.bg, 0.98):to_hex() }
        end
        return {
          -- tinted diagnostics
          DiagnosticVirtualTextHint = makeDiagnosticColor(theme.diag.hint),
          DiagnosticVirtualTextInfo = makeDiagnosticColor(theme.diag.info),
          DiagnosticVirtualTextWarn = makeDiagnosticColor(theme.diag.warning),
          DiagnosticVirtualTextError = makeDiagnosticColor(theme.diag.error),
          DiagnosticUnderlineHint = { undercurl = false, underdashed = true },
          DiagnosticUnderlineInfo = { undercurl = false, underdashed = true },
          DiagnosticUnderlineWarn = { undercurl = false, underdashed = true },
          DiagnosticUnderlineError = { undercurl = false, underdashed = true },
          -- dark completion
          Pmenu = { bg = theme.ui.bg_p1 },
          PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
          PmenuSbar = { bg = theme.ui.bg_p1 },
          PmenuThumb = { bg = theme.ui.bg_p2 },
          -- invisible window separator
          WinSeparator = { fg = theme.ui.nontext, bg = theme.ui.bg_gutter },
          -- nice tabline
          MiniTablineCurrent = { bg = theme.syn.fun, fg = theme.ui.bg },
          MiniTablineHidden = { link = "StatusLineNC" },
          MiniTablineVisible = { link = "StatusLineNC" },
          MiniTablineModifiedCurrent = { link = "MiniTablineCurrent" },
          MiniTablineModifiedHidden = { link = "MiniTablineHidden" },
          MiniTablineModifiedVisible = { link = "MiniTablineVisible" },
          -- visible MiniJump
          MiniJump = { link = "@comment.note" },
          -- document highlights
          LspReferenceRead = { bg = theme.diff.text },
          LspReferenceWrite = { bg = theme.diff.text, fg = theme.diag.warning, underline = false },
          LspReferenceText = { link = "None" },
        }
      end,
      colors = {
        theme = {
          wave = {
            ui = {
              bg_gutter = "#16161D", -- theme.ui.bg_m3
            },
          },
        },
      },
    },
  },

  -- lazydev.nvim
  {
    ft = "lua",
    config = function(_)
      require("lazydev").setup({
        integrations = { lspconfig = false },
      })
    end,
  },

  -- layers.nvim
  {
    config = function(_)
      require("layers").setup({})
    end,
  },

  -- nvim-dap
  {
    ft = "go",
    config = function(opts)
      require("dap-view").setup({
        winbar = {
          sections = { "watches", "scopes", "breakpoints", "threads", "repl" },
        },
        windows = {
          terminal = {
            hide = { "go" },
          },
        },
      })
      local dap = require("dap")
      dap.adapters = opts.adapters
      dap.configurations = opts.configurations
      -- ui tweaks
      vim.fn.sign_define("DapBreakpoint", { text = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "" })
      vim.fn.sign_define("DapStopped", {
        text = "",
        linehl = "debugPC",
      })
      -- treat dap-repl as a terminal
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("on_dap_repl", { clear = true }),
        pattern = "dap-repl",
        callback = function()
          vim.cmd("startinsert")
        end,
      })
      -- debug mode map overlay (Layers global set by layers-nvim in start/)
      DEBUG_MODE = Layers.mode.new("Debug Mode")
      DEBUG_MODE:auto_show_help()
      DEBUG_MODE:add_hook(function(_)
        vim.cmd("redrawstatus")
      end)
      dap.listeners.after.event_initialized["custom_maps"] = function()
        DEBUG_MODE:activate()
      end
      dap.listeners.before.event_terminated["custom_maps"] = function()
        DEBUG_MODE:deactivate()
      end
      dap.listeners.before.event_exited["custom_maps"] = function()
        DEBUG_MODE:deactivate()
      end
      DEBUG_MODE:keymaps({
        n = {
          {
            "e",
            function()
              require("dap-view").toggle(true)
            end,
            { desc = "open dap-view" },
          },
          {
            "n",
            function()
              dap.step_over()
            end,
            { desc = "step forward" },
          },
          {
            "N",
            function()
              dap.step_back()
            end,
            { desc = "step backward" },
          },
          {
            "t",
            function()
              require("dap.ui.widgets").centered_float(require("dap.ui.widgets").threads)
            end,
            { desc = "threads" },
          },
          {
            "v",
            function()
              require("dap.ui.widgets").centered_float(require("dap.ui.widgets").scopes)
            end,
            { desc = "variables" },
          },
          {
            "J",
            function()
              require("dap.ui.widgets").centered_float(require("dap.ui.widgets").expression)
            end,
            { desc = "hover value" },
          },
          {
            "b",
            function()
              dap.toggle_breakpoint()
            end,
            { desc = "toggle breakpoint" },
          },
          {
            "B",
            function()
              local cond = vim.fn.input("Breakpoint condition: ")
              dap.set_breakpoint(cond, nil, nil)
            end,
            { desc = "conditional break" },
          },
          {
            "c",
            function()
              dap.continue()
            end,
            { desc = "continue" },
          },
          {
            "C",
            function()
              dap.reverse_continue()
            end,
            { desc = "reverse continue" },
          },
          {
            ".",
            function()
              dap.run_to_cursor()
            end,
            { desc = "run to cursor" },
          },
          {
            "i",
            function()
              dap.step_into()
            end,
            { desc = "step into" },
          },
          {
            "o",
            function()
              dap.step_out()
            end,
            { desc = "step out" },
          },
          {
            "d",
            function()
              dap.down()
            end,
            { desc = "frame down" },
          },
          {
            "u",
            function()
              dap.up()
            end,
            { desc = "frame up" },
          },
          {
            "f",
            function()
              require("dap.ui.widgets").centered_float(require("dap.ui.widgets").frames)
            end,
            { desc = "frames" },
          },
          {
            "<esc>",
            function()
              DEBUG_MODE:deactivate()
            end,
            { desc = "exit" },
          },
          {
            "r",
            function()
              dap.restart()
            end,
            { desc = "restart" },
          },
          {
            "q",
            function()
              require("dap-view").close(true)
              dap.listeners.after.event_stopped["refresh_expr"] = nil
              vim.cmd("pclose")
              dap.terminate()
              dap.repl.close()
            end,
            { desc = "quit" },
          },
          {
            "Q",
            function()
              require("dap-view").close(true)
              dap.listeners.after.event_stopped["refresh_expr"] = nil
              vim.cmd("pclose")
              dap.terminate()
              dap.repl.close()
              dap.clear_breakpoints()
            end,
            { desc = "quit and clear" },
          },
        },
      })
      -- keymaps
      vim.keymap.set("n", "<leader>d", function()
        if dap.session() ~= nil then
          DEBUG_MODE:activate()
          return
        end
        if #require("dap.breakpoints").to_qf_list(require("dap.breakpoints").get()) == 0 then
          dap.toggle_breakpoint()
        end
        local ok, inTestfile, testName = pcall(SurroundingTestName)
        if ok and inTestfile then
          if testName ~= "" then
            dap.run({
              type = "go",
              name = testName,
              request = "launch",
              mode = "test",
              program = "./" .. vim.fn.fnamemodify(vim.fn.expand("%:.:h"), ":r"),
              args = { "-test.run", "^" .. testName .. "$" },
              buildFlags = "-tags=unit,integration,e2e",
            })
          else
            dap.run(dap.configurations.go[1])
          end
          return
        end
        dap.run_last()
        if dap.session() ~= nil then
          return
        end
        dap.continue()
      end, { desc = "auto launch (preference: test function > test file > last > ask)" })
      vim.keymap.set("n", "<leader>D", function()
        dap.continue()
      end, { desc = "continue or start fresh session" })
      vim.keymap.set("n", "<leader>sb", function()
        dap.list_breakpoints()
        vim.cmd.cwindow()
      end, { desc = "list breakpoints" })
      vim.keymap.set("n", "<leader>b", function()
        dap.toggle_breakpoint()
      end, { desc = "toggle breakpoint" })
      vim.keymap.set("n", "<leader>B", function()
        dap.clear_breakpoints()
      end, { desc = "clear all breakpoints" })
    end,
    opts = {
      adapters = {
        go = {
          type = "server",
          port = 2345,
          executable = {
            command = "dlv",
            args = { "dap", "-l", "127.0.0.1:2345" },
          },
          options = {
            initialize_timeout_sec = 20,
          },
        },
      },
      configurations = {
        go = {
          {
            type = "go",
            name = "tests",
            request = "launch",
            showLog = true,
            mode = "test",
            program = "./${relativeFileDirname}",
            buildFlags = "-tags=unit,integration,e2e",
          },
          {
            type = "go",
            name = "main",
            request = "launch",
            showLog = true,
            program = "${fileDirname}",
          },
          {
            type = "go",
            name = "main (with args)",
            request = "launch",
            showLog = true,
            program = "${fileDirname}",
            args = function()
              local args = {}
              vim.ui.input({ prompt = "args: " }, function(input)
                args = vim.split(input or "", " ")
              end)
              return args
            end,
          },
          {
            type = "go",
            name = "attach",
            mode = "local",
            request = "attach",
            showLog = true,
            processId = function()
              return require("dap.utils").pick_process()
            end,
          },
          {
            type = "go",
            name = "remote",
            mode = "remote",
            request = "attach",
            showLog = true,
            connect = { host = "127.0.0.1", port = "2345" },
          },
          {
            type = "go",
            name = "container",
            mode = "remote",
            request = "attach",
            showLog = true,
            connect = { host = "127.0.0.1", port = "2345" },
            substitutePath = {
              { from = vim.fn.getcwd(), to = "/app" },
            },
          },
        },
      },
    },
  },

  -- nvim-lint
  {
    defer = true,
    config = function(opts)
      require("lint").linters_by_ft = opts
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
    opts = {
      bash = { "shellcheck" },
      go = { "golangcilint" },
      markdown = { "proselint" },
      text = { "proselint" },
      nix = { "nix" },
    },
  },

  -- nvim-treesitter
  {
    config = function(_)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "*" },
        callback = function()
          local ok = pcall(vim.treesitter.start)
          if ok then
            vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  -- snacks.nvim: main setup + words/toggles
  {
    config = function(opts)
      require("snacks").setup(opts)
      vim.print = require("snacks").debug.inspect
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesActionRename",
        callback = function(event)
          require("snacks").rename.on_rename_file(event.data.from, event.data.to)
        end,
      })
      vim.keymap.set("n", "]]", function()
        Snacks.words.jump(vim.v.count1, true)
      end, { desc = "jump to next reference" })
      vim.keymap.set("n", "[[", function()
        Snacks.words.jump(-vim.v.count1, true)
      end, { desc = "jump to prev reference" })
      vim.keymap.set("n", "<leader>ob", function()
        Snacks.toggle.option("background", { on = "light", off = "dark" }):toggle()
      end, { desc = "toggle background" })
      vim.keymap.set("n", "<leader>od", function()
        Snacks.toggle.diagnostics():toggle()
      end, { desc = "toggle diagnostics" })
      vim.keymap.set("n", "<leader>oD", function()
        Snacks.toggle.dim():toggle()
      end, { desc = "toggle dimming" })
      vim.keymap.set("n", "<leader>oh", function()
        Snacks.toggle.inlay_hints():toggle()
      end, { desc = "toggle inlay hints" })
      vim.keymap.set("n", "<leader>oi", function()
        local toggle = Snacks.toggle.get("indentscope")
        if not toggle then
          toggle = Snacks.toggle.new({
            id = "indentscope",
            name = "indentscope",
            get = function()
              return not vim.g.miniindentscope_disable
            end,
            set = function(state)
              vim.g.miniindentscope_disable = not state
            end,
          })
        end
        toggle:toggle()
      end, { desc = "toggle indentscope" })
      vim.keymap.set("n", "<leader>oI", function()
        Snacks.toggle.words():toggle()
      end, { desc = "toggle illumination" })
      vim.keymap.set("n", "<leader>ol", function()
        Snacks.toggle.option("list"):toggle()
      end, { desc = "toggle list" })
      vim.keymap.set("n", "<leader>on", function()
        Snacks.toggle.option("number"):toggle()
      end, { desc = "toggle number" })
      vim.keymap.set("n", "<leader>op", function()
        local toggle = Snacks.toggle.get("pairs")
        if not toggle then
          toggle = Snacks.toggle.new({
            id = "pairs",
            name = "pairs",
            get = function()
              return not vim.g.minipairs_disable
            end,
            set = function(state)
              vim.g.minipairs_disable = not state
            end,
          })
        end
        toggle:toggle()
      end, { desc = "toggle auto pairs" })
      vim.keymap.set("n", "<leader>or", function()
        Snacks.toggle.option("relativenumber"):toggle()
      end, { desc = "toggle relativenumber" })
      vim.keymap.set("n", "<leader>os", function()
        Snacks.toggle.scroll():toggle()
      end, { desc = "toggle smooth scroll" })
      vim.keymap.set("n", "<leader>oS", function()
        Snacks.toggle.option("spell"):toggle()
      end, { desc = "toggle spell" })
      vim.keymap.set("n", "<leader>ot", function()
        Snacks.toggle.treesitter():toggle()
      end, { desc = "toggle treesitter" })
      vim.keymap.set("n", "<leader>ov", function()
        local toggle = Snacks.toggle.get("virtualedit")
        if not toggle then
          toggle = Snacks.toggle.new({
            id = "virtualedit",
            name = "virtualedit",
            get = function()
              return vim.o.virtualedit == "all"
            end,
            set = function(state)
              vim.opt.virtualedit = state and "all" or "block"
            end,
          })
        end
        toggle:toggle()
      end, { desc = "toggle virtualedit" })
      vim.keymap.set("n", "<leader>ow", function()
        Snacks.toggle.option("wrap"):toggle()
      end, { desc = "toggle wrap" })
      vim.keymap.set("n", "<leader>ox", function()
        Snacks.toggle.option("cursorcolumn"):toggle()
      end, { desc = "toggle cursorcolumn" })
      vim.keymap.set("n", "<leader>oz", function()
        Snacks.toggle.zen():toggle()
      end, { desc = "toggle zen mode" })
    end,
    opts = {
      bigfile = { enabled = true },
      notifier = {
        enabled = true,
        style = "minimal",
        top_down = false,
        width = { min = 20, max = 0.4 },
      },
      gitbrowse = {
        notify = false,
        open = function(url)
          vim.fn.setreg("+", url, "v")
        end,
      },
      input = { enabled = true },
      image = { enabled = true },
      picker = {
        layout = {
          preset = function()
            return vim.o.columns >= 120 and "ivy" or "vertical"
          end,
        },
        layouts = {
          buffers = {
            layout = {
              backdrop = false,
              width = 0.5,
              min_width = 80,
              height = 0.8,
              min_height = 30,
              box = "vertical",
              border = true,
              title = "{title} {live} {flags}",
              title_pos = "center",
              { win = "input", height = 1, border = "bottom" },
              { win = "list", border = "none" },
              { win = "preview", title = "{preview}", height = 0.7, border = "top" },
            },
          },
          bqflike = {
            layout = {
              position = "bottom",
              box = "vertical",
              width = 0,
              height = 0.5,
              title = " {source}",
              title_pos = "left",
              { win = "preview", height = 0.6 },
              { win = "list", border = "top" },
              { win = "input", height = 1, border = "none" },
            },
          },
        },
        ui_select = true,
        win = {
          input = {
            keys = {
              ["<c-space>"] = { "cycle_win", mode = { "i", "n" } },
              ["<right>"] = { "focus_preview", mode = { "i", "n" } },
            },
          },
          list = {
            keys = { ["<c-space>"] = "cycle_win" },
          },
          preview = {
            keys = {
              ["<c-space>"] = "cycle_win",
              ["<left>"] = "focus_input",
            },
          },
        },
      },
      quickfile = { enabled = true },
      scroll = {
        enabled = true,
        animate = { duration = { step = 15, total = 150 } },
      },
      statuscolumn = { enabled = true },
      styles = {
        zen = { backdrop = { transparent = false } },
      },
      toggle = { which_key = false },
      words = { enabled = true },
    },
  },

  -- snacks.nvim: picker keymaps
  {
    config = function(_)
      vim.keymap.set("n", "z=", function()
        require("snacks").picker.spelling()
      end, { desc = "spell suggest" })
      vim.keymap.set("n", "-", function()
        Snacks.picker.explorer({})
      end, { desc = "Tree" })
      vim.keymap.set("n", "<leader>u", function()
        Snacks.picker.undo({})
      end, { desc = "Undo" })
      vim.keymap.set("n", "<leader>f", function()
        require("snacks").picker.files()
      end, { desc = "find files" })
      vim.keymap.set("n", "<leader>F", function()
        require("snacks").picker.smart()
      end, { desc = "find more files smartly" })
      vim.keymap.set("n", "<leader>t", function()
        Snacks.picker.buffers({
          current = false,
          layout = "buffers",
          auto_confirm = true,
          win = { input = { keys = { ["<c-space>"] = { "cancel", mode = { "i", "n" } } } } },
        })
      end, { desc = "Buffers" })
      vim.keymap.set("n", "<leader>:", function()
        Snacks.picker.command_history({})
      end, { desc = "Command History" })
      vim.keymap.set("n", "<leader>/", function()
        Snacks.picker.grep()
      end, { desc = "Grep" })
      vim.keymap.set({ "n", "x" }, "<leader>*", function()
        require("snacks").picker.grep_word({})
      end, { desc = "grep word" })
      vim.keymap.set("n", '<leader>s"', function()
        Snacks.picker.registers()
      end, { desc = "Registers" })
      vim.keymap.set("n", "<leader>sa", function()
        Snacks.picker.autocmds()
      end, { desc = "Autocmds" })
      vim.keymap.set("n", "<leader>sc", function()
        require("snacks").picker.cliphist({})
      end, { desc = "Cliphist" })
      vim.keymap.set("n", "<leader>sd", function()
        Snacks.picker.diagnostics({})
      end, { desc = "Diagnostics" })
      vim.keymap.set("n", "<leader>sh", function()
        Snacks.picker.help()
      end, { desc = "Help Pages" })
      vim.keymap.set("n", "<leader>sp", function()
        Snacks.picker.pickers()
      end, { desc = "Pickers" })
      vim.keymap.set("n", "<leader>sH", function()
        Snacks.picker.highlights()
      end, { desc = "Highlights" })
      vim.keymap.set("n", "<leader>si", function()
        Snacks.picker.icons()
      end, { desc = "Icons" })
      vim.keymap.set("n", "<leader>sk", function()
        Snacks.picker.keymaps()
      end, { desc = "Keymaps" })
      vim.keymap.set("n", "<leader>sM", function()
        Snacks.picker.man()
      end, { desc = "Man Pages" })
      vim.keymap.set("n", "<leader>sm", function()
        Snacks.picker.marks()
      end, { desc = "Marks" })
      vim.keymap.set("n", "<leader>sr", function()
        Snacks.picker.recent()
      end, { desc = "Recent" })
      vim.keymap.set("n", "<leader><leader>", function()
        Snacks.picker.resume({})
      end, { desc = "Same Search again" })
      vim.keymap.set("n", "<leader>ss", function()
        Snacks.picker.resume({})
      end, { desc = "Resume" })
      vim.keymap.set("n", "go", function()
        Snacks.picker.lsp_symbols({ layout = "bqflike" })
      end, { desc = "lsp: show symbols" })
      vim.keymap.set("n", "gO", function()
        Snacks.picker.lsp_workspace_symbols({ layout = "bqflike" })
      end, { desc = "lsp: show all symbols" })
      vim.keymap.set("n", "gd", function()
        Snacks.picker.lsp_definitions({ layout = "bqflike" })
      end, { desc = "lsp: show definition" })
      vim.keymap.set("n", "gD", function()
        Snacks.picker.lsp_type_definitions({ layout = "bqflike" })
      end, { desc = "lsp: show type definition" })
      vim.keymap.set("n", "gi", function()
        Snacks.picker.lsp_implementations({ layout = "bqflike" })
      end, { desc = "lsp: show implementations" })
      vim.keymap.set("n", "gr", function()
        Snacks.picker.lsp_references({ layout = "bqflike" })
      end, { desc = "lsp: show refs" })
      vim.keymap.set("n", "gh", function()
        Snacks.picker.lsp_incoming_calls({ layout = "bqflike" })
      end, { desc = "lsp: show incoming" })
      vim.keymap.set("n", "gH", function()
        Snacks.picker.lsp_outgoing_calls({ layout = "bqflike" })
      end, { desc = "lsp: show outgoing" })
    end,
  },

  -- snacks.nvim: git keymaps
  {
    config = function(_)
      vim.keymap.set("n", "<leader>gp", function()
        require("snacks").picker.gh_pr()
      end, { desc = "Show GitHub Pull Requests" })
      vim.keymap.set("n", "<leader>gd", function()
        require("snacks").picker.git_diff()
      end, { desc = "Show Git Diff" })
      vim.keymap.set("n", "<leader>gb", function()
        require("snacks").picker.git_log_line()
      end, { desc = "Show Git Blame" })
      vim.keymap.set("n", "<leader>gB", function()
        require("snacks").picker.git_branches()
      end, { desc = "Show Git Branches" })
      vim.keymap.set({ "n", "x" }, "gy", function()
        require("snacks").gitbrowse({ branch = require("mini.git").get_buf_data(0).head })
      end, { desc = "Copy Git URL" })
      vim.keymap.set("n", "<leader>gl", function()
        Snacks.picker.git_log()
      end, { desc = "Git Log" })
      vim.keymap.set("n", "<leader>gL", function()
        Snacks.picker.git_log_file()
      end, { desc = "Git Log for this file" })
      vim.keymap.set("n", "<leader>gs", function()
        Snacks.picker.git_status()
      end, { desc = "Git Status" })
      vim.keymap.set("n", "<leader>gc", function()
        Snacks.picker.git_branches({
          confirm = function(picker, item)
            picker:close()
            if item then
              vim.fn.system("git read-tree " .. item.text:match("^%*?%s*(%S+)"))
            end
          end,
        })
      end, { desc = "Set git base to a branch" })
      vim.keymap.set("n", "<leader>gC", function()
        Snacks.picker.git_log({
          confirm = function(picker, item)
            picker:close()
            if item then
              vim.fn.system("git read-tree " .. item.text:match("^(%S+)"))
            end
          end,
        })
      end, { desc = "Set git base to a commit" })
      vim.keymap.set("n", "<leader>gr", function()
        vim.fn.system("git reset")
      end, { desc = "Reset git base" })
    end,
  },

  -- mini.ai
  {
    defer = true,
    config = function(opts)
      MINI_AI_PARAMS = nil
      local module_opts = {
        silent = true,
        n_lines = 200,
        mappings = {
          goto_left = "[",
          goto_right = "]",
        },
      }
      module_opts.custom_textobjects = {
        -- braces
        b = { { "%b()", "%b[]", "%b{}" }, "^.().*().$" },
        -- disable quote, use string to free up quickfix navigation
        q = false,
        s = { { "%b''", '%b""', "%b``" }, "^.().*().$" },
        -- subword
        W = {
          {
            "%u[%l%d]+%f[^%l%d]",
            "%f[%S][%l%d]+%f[^%l%d]",
            "%f[%P][%l%d]+%f[^%l%d]",
            "^[%l%d]+%f[^%l%d]",
          },
          "^().*()$",
        },
        N = require("mini.extra").gen_ai_spec.number(),
      }
      for _, cfg in pairs(opts) do
        if cfg.a ~= nil and cfg.i ~= nil then
          module_opts.custom_textobjects = vim.tbl_deep_extend("force", module_opts.custom_textobjects, {
            [cfg.letter] = require("mini.ai").gen_spec.treesitter({ a = cfg.a, i = cfg.i }, {}),
          })
        end
      end
      require("mini.ai").setup(module_opts)
      -- jump keymaps (derived from opts)
      vim.keymap.set("n", ",", function()
        if MINI_AI_PARAMS then
          pcall(require("mini.ai").move_cursor, unpack(MINI_AI_PARAMS))
        end
      end, { desc = "repeat last mini.ai jump" })
      for name, cfg in pairs(opts) do
        if cfg.jump_target then
          vim.keymap.set("n", "]" .. cfg.letter, function()
            MINI_AI_PARAMS = { "left", cfg.jump_target, cfg.letter, { search_method = "next", n_times = vim.v.count1 } }
            pcall(require("mini.ai").move_cursor, unpack(MINI_AI_PARAMS))
          end, { desc = "jump to beginning of next " .. name })
          vim.keymap.set("n", "[" .. cfg.letter, function()
            MINI_AI_PARAMS =
              { "left", cfg.jump_target, cfg.letter, { search_method = "cover_or_prev", n_times = vim.v.count1 } }
            pcall(require("mini.ai").move_cursor, unpack(MINI_AI_PARAMS))
          end, { desc = "jump to beginning of current or previous " .. name })
          if cfg.letter:match("%l") then
            vim.keymap.set("n", "]" .. cfg.letter:upper(), function()
              MINI_AI_PARAMS =
                { "right", cfg.jump_target, cfg.letter, { search_method = "cover_or_next", n_times = vim.v.count1 } }
              pcall(require("mini.ai").move_cursor, unpack(MINI_AI_PARAMS))
            end, { desc = "jump to end of current or next " .. name })
            vim.keymap.set("n", "[" .. cfg.letter:upper(), function()
              MINI_AI_PARAMS =
                { "right", cfg.jump_target, cfg.letter, { search_method = "prev", n_times = vim.v.count1 } }
              pcall(require("mini.ai").move_cursor, unpack(MINI_AI_PARAMS))
            end, { desc = "jump to end of previous " .. name })
          end
        end
      end
    end,
    opts = {
      argument = { letter = "a", a = "@parameter.outer", i = "@parameter.inner", jump_target = "i" },
      brace = { letter = "b", jump_target = "a" },
      call = { letter = "c", a = "@call.outer", i = "@call.inner", jump_target = "a" },
      ["function"] = { letter = "f", a = "@function.outer", i = "@function.inner", jump_target = "a" },
      ["if"] = { letter = "i", a = "@conditional.outer", i = "@conditional.inner", jump_target = "a" },
      ["loop"] = { letter = "l", a = "@loop.outer", i = "@loop.inner", jump_target = "a" },
      string = { letter = "s", jump_target = "i" },
      type = { letter = "t", a = { "@class.outer" }, i = { "@class.inner" }, jump_target = "a" },
      subword = { letter = "W", jump_target = "a" },
    },
  },

  -- mini.bracketed
  {
    defer = true,
    config = function(opts)
      require("mini.bracketed").setup(opts)
    end,
    opts = {
      conflict = { suffix = "x" },
      diagnostic = { suffix = "d", options = { float = true } },
      jump = { suffix = "j", options = { wrap = false } },
      quickfix = { suffix = "q" },
      yank = { suffix = "y" },
      -- disabled
      buffer = { suffix = "" },
      comment = { suffix = "" },
      file = { suffix = "" },
      indent = { suffix = "" },
      location = { suffix = "" },
      oldfile = { suffix = "" },
      treesitter = { suffix = "n" },
      undo = { suffix = "" },
      window = { suffix = "" },
    },
  },

  -- mini.bufremove
  {
    defer = true,
    config = function(_)
      require("mini.bufremove").setup({})
      vim.keymap.set("n", "<leader>w", function()
        require("mini.bufremove").delete(0, false)
      end, { desc = "remove buffer" })
    end,
  },

  -- mini.clue
  {
    config = function(_)
      local miniclue = require("mini.clue")
      miniclue.setup({
        window = {
          delay = 200,
          config = { width = "auto" },
        },
        triggers = {
          -- custom modes
          { mode = "n", keys = "<leader>g" },
          { mode = "x", keys = "<leader>g" },
          { mode = "n", keys = "<leader>o" },
          { mode = "x", keys = "<leader>o" },
          { mode = "n", keys = "s" },
          { mode = "x", keys = "s" },
          -- mini.bracketed
          { mode = "n", keys = "]" },
          { mode = "n", keys = "[" },
          { mode = "x", keys = "]" },
          { mode = "x", keys = "[" },
          -- builtin
          { mode = "n", keys = "<leader>" },
          { mode = "x", keys = "<leader>" },
          { mode = "n", keys = "g" },
          { mode = "x", keys = "g" },
          { mode = "n", keys = "'" },
          { mode = "n", keys = "`" },
          { mode = "n", keys = '"' },
          { mode = "x", keys = "'" },
          { mode = "x", keys = "`" },
          { mode = "x", keys = '"' },
          { mode = "i", keys = "<C-r>" },
          { mode = "c", keys = "<C-r>" },
          { mode = "n", keys = "<C-w>" },
          { mode = "n", keys = "z" },
          { mode = "x", keys = "z" },
        },
        clues = {
          miniclue.gen_clues.g(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows({ submode_resize = true }),
          miniclue.gen_clues.z(),
        },
      })
    end,
  },

  -- mini.diff
  {
    defer = true,
    config = function(opts)
      require("mini.diff").setup(opts)
      vim.keymap.set("n", "<leader>gg", function()
        require("mini.diff").toggle_overlay(0)
      end, { desc = "Show details" })
    end,
    opts = {
      view = {
        style = "sign",
        signs = { add = "│", change = "│", delete = "_" },
        priority = 20,
      },
      mappings = {
        apply = "ga",
        reset = "gR",
        textobject = "ig",
        goto_first = "[G",
        goto_prev = "[g",
        goto_next = "]g",
        goto_last = "]G",
      },
      options = { wrap_goto = true },
    },
  },

  -- mini.files
  {
    defer = true,
    config = function(opts)
      require("mini.files").setup(opts)
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          local buf_id = args.data.buf_id
          vim.keymap.set("n", "<left>", MiniFiles.go_out, { buffer = buf_id })
          vim.keymap.set("n", "<right>", function()
            MiniFiles.go_in({ close_on_file = true })
          end, { buffer = buf_id })
          vim.keymap.set("n", "<s-right>", MiniFiles.go_in, { buffer = buf_id })
          vim.keymap.set("n", "<esc>", MiniFiles.close, { buffer = buf_id })
        end,
      })
      vim.keymap.set("n", "_", function()
        require("mini.files").open(vim.api.nvim_buf_get_name(0))
      end, { desc = "browse files" })
    end,
  },

  -- mini.git
  {
    defer = true,
    config = function(_)
      require("mini.git").setup({})
    end,
  },

  -- mini.hipatterns
  {
    defer = true,
    config = function(opts)
      opts.highlighters.hex_color = require("mini.hipatterns").gen_highlighter.hex_color()
      require("mini.hipatterns").setup(opts)
    end,
    opts = {
      highlighters = {
        fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "@text.warning" },
        hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "@text.danger" },
        bug = { pattern = "%f[%w]()BUG()%f[%W]", group = "@text.danger" },
        todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "@text.todo" },
        note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "@text.note" },
      },
    },
  },

  -- mini.icons
  {
    config = function(opts)
      require("mini.icons").setup(opts)
      MiniIcons.tweak_lsp_kind()
    end,
    opts = {
      lsp = {
        class = { glyph = "󰠱" },
        color = { glyph = "󰏘" },
        constant = { glyph = "󰏿" },
        constructor = { glyph = "󰒓" },
        enum = { glyph = "" },
        enumMember = { glyph = "" },
        event = { glyph = "󱐋" },
        field = { glyph = "󰇽" },
        file = { glyph = "󰈔" },
        folder = { glyph = "󰉋" },
        ["function"] = { glyph = "󰊕" },
        interface = { glyph = "" },
        keyword = { glyph = "󰌋" },
        method = { glyph = "󰆧" },
        module = { glyph = "󰅩" },
        operator = { glyph = "󰆕" },
        property = { glyph = "󰜢" },
        reference = { glyph = "" },
        snippet = { glyph = "" },
        struct = { glyph = "" },
        text = { glyph = "󰉿" },
        typeParameter = { glyph = "󰅲" },
        unit = { glyph = "" },
        value = { glyph = "󰎠" },
        variable = { glyph = "󰂡" },
      },
    },
  },

  -- mini.indentscope
  {
    defer = true,
    config = function(opts)
      require("mini.indentscope").setup(opts)
    end,
    opts = {
      draw = {
        animation = function()
          return 0
        end,
      },
      symbol = "🞗",
      options = { try_as_border = true },
      mappings = {
        object_scope = "i<space>",
        object_scope_with_border = "a<space>",
        goto_top = "[<space>",
        goto_bottom = "]<space>",
      },
    },
  },

  -- mini.jump
  {
    defer = true,
    config = function(_)
      require("mini.jump").setup({})
    end,
  },

  -- mini.operators
  {
    defer = true,
    config = function(opts)
      require("mini.operators").setup(opts)
    end,
    opts = {
      replace = { prefix = "R" },
      exchange = { prefix = "X" },
      evaluate = { prefix = "g=" },
      multiply = { prefix = "gm" },
      sort = { prefix = "gs" },
    },
  },

  -- mini.pairs
  {
    event = "InsertEnter",
    config = function(opts)
      require("mini.pairs").setup(opts)
    end,
    opts = {
      mappings = {
        ["("] = { action = "open", pair = "()", neigh_pattern = ".[%s%)]" },
        ["["] = { action = "open", pair = "[]", neigh_pattern = ".[%s%)}%]]" },
        ["{"] = { action = "open", pair = "{}", neigh_pattern = ".[%s%)}%]]" },
        [")"] = { action = "close", pair = "()", neigh_pattern = "[^\\%s]." },
        ["]"] = { action = "close", pair = "[]", neigh_pattern = "[^\\%s]." },
        ["}"] = { action = "close", pair = "{}", neigh_pattern = "[^\\%s]." },
        ['"'] = { action = "closeopen", pair = '""', neigh_pattern = "[^%w\\][^%w]", register = { cr = false } },
        ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%w\\][^%w]", register = { cr = false } },
        ["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^%w\\][^%w]", register = { cr = false } },
      },
    },
  },

  -- mini.sessions
  {
    config = function(opts)
      require("mini.sessions").setup(opts)
      vim.keymap.set("n", "<leader>S", function()
        require("mini.sessions").write(".session.nvim", { force = true })
      end, { desc = "save session" })
    end,
    opts = {
      autoread = true,
      autowrite = true,
      file = ".session.nvim",
    },
  },

  -- mini.splitjoin
  {
    defer = true,
    config = function(_)
      require("mini.splitjoin").setup({
        mappings = { toggle = "" },
        split = {
          hooks_post = {
            require("mini.splitjoin").gen_hook.add_trailing_separator({
              brackets = { "%b()", "%b[]", "%b{}" },
            }),
          },
        },
        join = {
          hooks_post = {
            require("mini.splitjoin").gen_hook.del_trailing_separator({
              brackets = { "%b()", "%b[]", "%b{}" },
            }),
          },
        },
      })
      vim.keymap.set("n", "gS", function()
        require("mini.splitjoin").toggle()
      end, { desc = "split/join" })
    end,
  },

  -- mini.statusline
  {
    config = function(opts)
      require("mini.statusline").setup(opts)
    end,
    opts = {
      content = {
        active = function()
          local function inverted(group)
            local hl = vim.api.nvim_get_hl(0, { name = group })
            local name = group .. "Inverted"
            vim.api.nvim_set_hl(0, name, { fg = hl.bg, bg = "NONE", force = true })
            return name
          end
          local MiniStatusline = require("mini.statusline")
          local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
          if DEBUG_MODE ~= nil and DEBUG_MODE:active() then
            mode = "DEBUG"
            mode_hl = "Substitute"
          end
          local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
          local filename = MiniStatusline.section_filename({ trunc_width = 140 })
          local searchcount = MiniStatusline.section_searchcount({ trunc_width = 75 })
          return MiniStatusline.combine_groups({
            { hl = mode_hl, strings = { mode:upper() } },
            {
              hl = inverted(mode_hl),
              strings = {
                vim.b.minigit_summary and vim.b.minigit_summary.head_name and " " .. vim.b.minigit_summary.head_name
                  or "",
              },
            },
            MiniStatusline.combine_groups({
              {
                hl = "@diff.plus",
                strings = {
                  (vim.b.minidiff_summary and vim.b.minidiff_summary.add or 0) > 0
                    and "+" .. vim.b.minidiff_summary.add,
                },
              },
              {
                hl = "@diff.delta",
                strings = {
                  (vim.b.minidiff_summary and vim.b.minidiff_summary.change or 0) > 0
                    and "~" .. vim.b.minidiff_summary.change,
                },
              },
              {
                hl = "@diff.minus",
                strings = {
                  (vim.b.minidiff_summary and vim.b.minidiff_summary.delete or 0) > 0
                    and "-" .. vim.b.minidiff_summary.delete,
                },
              },
            }):gsub("# ", "#"),
            { hl = "DiagnosticInfo", strings = { diagnostics } },
            "%<", -- Mark general truncate point
            { hl = "StatusLine", strings = { filename } },
            "%=", -- End left alignment
            {
              hl = "StatusLine",
              strings = {
                searchcount,
                vim.bo.filetype ~= ""
                  and require("mini.icons").get("filetype", vim.bo.filetype) .. " " .. vim.bo.filetype,
              },
            },
            {
              hl = "ModeMsg",
              strings = {
                vim.fn.reg_recording() ~= "" and "recording @" .. vim.fn.reg_recording(),
              },
            },
            {
              hl = inverted(mode_hl),
              strings = { "%p%%/%L" },
            },
            { hl = mode_hl, strings = { "%l:%v" } },
          })
        end,
      },
    },
  },

  -- mini.surround
  {
    defer = true,
    config = function(opts)
      require("mini.surround").setup(opts)
    end,
    opts = {
      search_method = "cover_or_next",
      silent = true,
    },
  },

  -- mini.tabline
  {
    config = function(opts)
      require("mini.tabline").setup(opts)
    end,
    opts = {
      tabpage_section = "right",
      format = function(buf_id, label)
        local suffix = ""
        if vim.bo[buf_id].modified then
          suffix = "● "
        elseif vim.bo[buf_id].readonly then
          suffix = " "
        end
        return MiniTabline.default_format(buf_id, label) .. suffix
      end,
    },
  },
}
