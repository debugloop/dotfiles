local function inject(spec)
  if type(spec) ~= "table" then
    vim.notify("Encountered bad plugin spec. Must use a table, not string. Check config.", vim.log.levels.ERROR)
    return spec
  end

  if spec["clone"] then
    return spec
  end

  if spec["dir"] == nil and spec["dev"] ~= true then
    local plugin_name = spec[1]:match("[^/]+$")
    local nixpkgs_dir = NIXPLUG_PATH .. "/" .. plugin_name:gsub("%.", "-")
    if vim.fn.isdirectory(nixpkgs_dir) == 1 then
      spec["dir"] = nixpkgs_dir
    end
  end
  return spec
end

local function inject_all(specs)
  for _, spec in ipairs(specs) do
    spec = inject(spec)
    if spec.dependencies ~= nil then
      spec.dependencies = inject_all(spec.dependencies)
    end
  end
  return specs
end

return inject_all({
  {
    "mistweaverco/kulala.nvim",
    ft = { "http", "rest" },
    opts = {
      -- your configuration comes here
      global_keymaps = true,
    },
  },

  {
    "saghen/blink.cmp",
    lazy = false, -- it handles itself and is an integral part anyhow
    dependencies = {
      { "rafamadriz/friendly-snippets" },
    },
    opts = {
      appearance = {
        use_nvim_cmp_as_default = true,
      },
      completion = {
        accept = {
          auto_brackets = {
            enabled = false,
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 50,
        },
        -- keyword = {
        --   range = "full",
        -- },
        list = {
          selection = {
            preselect = false,
            auto_insert = true,
          },
        },
        menu = {
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
      -- fuzzy = {
      --   implementation = "prefer_rust",
      --   -- prebuilt_binaries = {
      --   --   download = false,
      --   --   ignore_version_mismatch = true,
      --   -- },
      -- },
      keymap = {
        preset = "enter",
        ["<tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<s-tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<c-u>"] = { "scroll_documentation_up", "fallback" },
        ["<c-d>"] = { "scroll_documentation_down", "fallback" },
        ["<c-e>"] = { "cancel", "fallback" },
        ["<cr>"] = { "select_and_accept", "fallback" },
      },
      signature = {
        enabled = true,
        trigger = {
          show_on_insert = true,
        },
        window = {
          direction_priority = { "s", "n" },
        },
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

  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        css = { "prettier" },
        go = { "gofumpt", "goimports", "goimports-reviser" },
        html = { "prettier" },
        http = { "kulala-fmt" },
        javascript = { "prettier" },
        lua = { "stylua" },
        nix = { "alejandra" },
        templ = { "templ", "injected" },
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
    init = function()
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
    end,
  },

  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewPR" },
    keys = {
      {
        "<leader>gd",
        "<cmd>DiffviewOpen<cr>",
        desc = "Open Diffview",
      },
    },
    opts = {
      use_icons = false,
      default_args = {
        DiffviewOpen = { "--imply-local", "--untracked-files=no" },
      },
      keymaps = {
        view = {
          ["<esc>"] = "<cmd>tabc<cr>",
        },
        diff1 = {
          ["<esc>"] = "<cmd>tabc<cr>",
        },
        diff2 = {
          ["<esc>"] = "<cmd>tabc<cr>",
        },
        diff3 = {
          ["<esc>"] = "<cmd>tabc<cr>",
        },
        diff4 = {
          ["<esc>"] = "<cmd>tabc<cr>",
        },
        file_panel = {
          ["<esc>"] = "<cmd>tabc<cr>",
        },
        file_history_panel = {
          ["<esc>"] = "<cmd>tabc<cr>",
        },
        option_panel = {
          ["<esc>"] = "<cmd>tabc<cr>",
        },
      },
      hooks = {
        diff_buf_read = function(_)
          vim.opt_local.wrap = false
          vim.opt_local.relativenumber = false
          vim.opt_local.cursorline = false
        end,
      },
    },
    config = function(_, opts)
      require("diffview").setup(opts)
      vim.api.nvim_create_user_command("DiffviewPR", function()
        vim.cmd("DiffviewOpen origin/HEAD...HEAD")
      end, { desc = "open diffview for current PR" })
    end,
  },

  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    event = "UIEnter",
    config = function(_, opts)
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
          WinSeparator = { fg = theme.ui.bg_dim, bg = theme.ui.bg_dim },
          -- nice tabline
          MiniTablineCurrent = { bg = theme.syn.fun, fg = theme.ui.bg },
          MiniTablineHidden = { link = "StatusLineNC" },
          MiniTablineVisible = { link = "StatusLineNC" },
          MiniTablineModifiedCurrent = { link = "MiniTablineCurrent" },
          MiniTablineModifiedHidden = { link = "MiniTablineHidden" },
          MiniTablineModifiedVisible = { link = "MiniTablineVisible" },
          -- visible MiniJump
          MiniJump = { link = "@comment.note" },
          -- less prominent qf title
          -- BqfPreviewTitle = { link = "BqfPreviewBorder" },
          NoiceCmdlineIcon = { fg = theme.diag.info, bg = theme.ui.bg },
          NoiceCmdlinePopupBorder = { fg = theme.diag.info, bg = theme.ui.bg },
          NoiceCmdlinePopupTitle = { fg = theme.diag.info, bg = theme.ui.bg },
          NoiceConfirmBorder = { fg = theme.diag.info, bg = theme.ui.bg },
          -- document highlights
          LspReferenceText = { link = "CurSearch" },
          LspReferenceRead = { link = "CurSearch" },
          LspReferenceWrite = { link = "IncSearch" },
        }
      end,
      colors = {
        theme = {
          wave = {
            ui = {
              bg_gutter = "#1a1a22", -- theme.ui.bg_m1
            },
          },
        },
      },
    },
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter" },
      { "echasnovski/mini.icons" },
    },
    opts = {},
  },

  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects" },
    },
    opts = {
      n_lines = 200,
    },
    config = function(_, opts)
      opts.custom_textobjects = {
        -- arg
        a = require("mini.ai").gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),
        -- braces
        b = { { "%b()", "%b[]", "%b{}" }, "^.().*().$" },
        -- block
        B = require("mini.ai").gen_spec.treesitter({ a = "@block.outer", i = "@block.inner" }),
        -- call
        c = require("mini.ai").gen_spec.treesitter({ a = "@call.outer", i = "@call.inner" }),
        -- function / method
        f = require("mini.ai").gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
        -- if
        i = require("mini.ai").gen_spec.treesitter({
          a = "@conditional.outer",
          i = "@conditional.inner",
        }),
        -- loop
        L = require("mini.ai").gen_spec.treesitter({ a = "@loop.outer", i = "@loop.inner" }),
        -- disable quote, I use string
        q = false,
        -- string
        s = { { "%b''", '%b""', "%b``" }, "^.().*().$" },
        -- type
        t = require("mini.ai").gen_spec.treesitter({
          a = { "@customtype.outer", "@type.outer" },
          i = { "@customtype.inner", "@type.inner" },
        }),
        -- defaults include
        -- (, ), [, ], {, }, <, >, ", ', `, ?, t, <space>
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
      }
      require("mini.ai").setup(opts)
    end,
  },

  {
    "echasnovski/mini.bracketed",
    event = "VeryLazy",
    opts = {
      conflict = {
        suffix = "x",
      },
      diagnostic = {
        suffix = "d",
        options = {
          float = true,
        },
      },
      jump = {
        suffix = "j",
        options = {
          wrap = false,
        },
      },
      quickfix = {
        suffix = "q",
      },
      yank = {
        suffix = "y",
      },
      -- disable the rest
      buffer = { suffix = "" },
      comment = { suffix = "" },
      file = { suffix = "" },
      indent = { suffix = "" },
      location = { suffix = "" },
      oldfile = { suffix = "" },
      treesitter = { suffix = "" },
      undo = { suffix = "" },
      window = { suffix = "" },
    },
  },

  {
    "echasnovski/mini.bufremove",
    keys = {
      {
        "<leader><tab>",
        function()
          require("mini.bufremove").delete(0, false)
        end,
        desc = "remove buffer",
      },
    },
    opts = {},
  },

  {
    "echasnovski/mini.clue",
    event = "VeryLazy",
    config = function(_, _)
      local miniclue = require("mini.clue")
      require("mini.clue").setup({
        window = {
          delay = 200,
          config = {
            width = "auto",
          },
        },
        triggers = {
          -- custom modes
          { mode = "n", keys = "<leader>d" },
          { mode = "x", keys = "<leader>d" },
          { mode = "n", keys = "<leader>g" },
          { mode = "x", keys = "<leader>g" },
          { mode = "n", keys = "<leader>o" },
          { mode = "x", keys = "<leader>o" },
          { mode = "n", keys = "<leader>q" },
          { mode = "x", keys = "<leader>q" },
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
          -- builtin
          miniclue.gen_clues.g(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows({
            submode_resize = true,
          }),
          miniclue.gen_clues.z(),
        },
      })
    end,
  },

  {
    "echasnovski/mini.diff",
    event = "VeryLazy",
    keys = {
      {
        "<leader>gg",
        function()
          require("mini.diff").toggle_overlay(0)
        end,
        desc = "Show details",
      },
      {
        "<leader>gc",
        function()
          require("mini.extra").pickers.git_branches({}, {
            source = {
              choose = function(item)
                vim.fn.system("git read-tree " .. item:match("^%*?%s*(%S+)"))
              end,
            },
          })
        end,
        desc = "Set git base to a branch",
      },
      {
        "<leader>gC",
        function()
          require("mini.extra").pickers.git_commits({}, {
            source = {
              choose = function(item)
                vim.fn.system("git read-tree " .. item:match("^(%S+)"))
              end,
            },
          })
        end,
        desc = "Set git base to a commit",
      },
      {
        "<leader>gr",
        function()
          vim.fn.system("git reset")
        end,
        desc = "Reset git base",
      },
    },
    opts = {
      view = {
        style = "sign",
        signs = { add = "┃", change = "┃", delete = "_" },
        priority = 20,
      },
      mappings = {
        apply = "ga",
        reset = "gR",
        textobject = "gh",
        goto_first = "[G",
        goto_prev = "[g",
        goto_next = "]g",
        goto_last = "]G",
      },
      options = {
        wrap_goto = true,
      },
    },
  },

  {
    "echasnovski/mini.files",
    keys = {
      {
        "_",
        function()
          require("mini.files").open(vim.api.nvim_buf_get_name(0))
        end,
        desc = "browse files",
      },
    },
  },

  {
    "echasnovski/mini-git",
    name = "mini.git",
    keys = {
      {
        "<leader>gi",
        mode = { "n", "x" },
        function()
          require("mini.git").show_at_cursor()
        end,
        desc = "Show Git info",
      },
    },
    opts = {},
  },

  {
    "echasnovski/mini.hipatterns",
    event = "VeryLazy",
    enabled = false,
    opts = {
      highlighters = {
        fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "@text.warning" },
        hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "@text.danger" },
        bug = { pattern = "%f[%w]()BUG()%f[%W]", group = "@text.danger" },
        todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "@text.todo" },
        note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "@text.note" },
      },
    },
    config = function(_, opts)
      opts.highlighters.hex_color = require("mini.hipatterns").gen_highlighter.hex_color()
      require("mini.hipatterns").setup(opts)
    end,
  },

  {
    "echasnovski/mini.icons",
    opts = {
      lsp = {
        class = { glyph = "󰠱" },
        color = { glyph = "󰏘" },
        constant = { glyph = "󰏿" },
        constructor = { glyph = "󰒓" },
        enum = { glyph = "" },
        enumMember = { glyph = "" },
        event = { glyph = "󱐋" },
        field = { glyph = "󰇽" },
        file = { glyph = "󰈔" },
        folder = { glyph = "󰉋" },
        ["function"] = { glyph = "󰊕" },
        interface = { glyph = "" },
        keyword = { glyph = "󰌋" },
        method = { glyph = "󰆧" },
        module = { glyph = "󰅩" },
        operator = { glyph = "󰆕" },
        property = { glyph = "󰜢" },
        reference = { glyph = "" },
        snippet = { glyph = "" },
        struct = { glyph = "" },
        text = { glyph = "󰉿" },
        typeParameter = { glyph = "󰅲" },
        unit = { glyph = "" },
        value = { glyph = "󰎠" },
        variable = { glyph = "󰂡" },
      },
    },
    config = function(_, opts)
      require("mini.icons").setup(opts)
      MiniIcons.tweak_lsp_kind()
    end,
  },

  {
    "echasnovski/mini.indentscope",
    event = "VeryLazy",
    opts = {
      draw = {
        animation = function()
          return 0
        end,
      },
      symbol = "·",
      options = {
        try_as_border = true,
      },
      mappings = {
        object_scope = "i<tab>",
        object_scope_with_border = "a<tab>",
        goto_top = "[<tab>",
        goto_bottom = "]<tab>",
      },
    },
    config = function(_, opts)
      require("mini.indentscope").setup(opts)
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("indentscope_python", {}),
        pattern = "python",
        callback = function()
          require("mini.indentscope").config.options.border = "top"
        end,
      })
      vim.api.nvim_create_autocmd({ "InsertEnter" }, {
        group = vim.api.nvim_create_augroup("indentscope_insert_enter", { clear = true }),
        pattern = "*",
        callback = function()
          vim.g.miniindentscope_disable = true
        end,
      })
      vim.api.nvim_create_autocmd({ "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("indentscope_insert_leave", { clear = true }),
        pattern = "*",
        callback = function(event)
          vim.g.miniindentscope_disable = false -- re-enable indent guides
        end,
      })
    end,
  },

  {
    "echasnovski/mini.jump",
    keys = { "f", "F", "t", "T" },
    opts = {},
  },

  {
    "echasnovski/mini.operators",
    event = "VeryLazy",
    keys = { "R", "X", "g" },
    opts = {
      replace = {
        prefix = "R",
      },
      exchange = {
        prefix = "X",
      },
      -- defaults:
      evaluate = {
        prefix = "g=",
      },
      multiply = {
        prefix = "gm",
      },
      sort = {
        prefix = "gs",
      },
    },
  },

  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    opts = {
      mappings = {
        ["("] = {
          action = "open",
          pair = "()",
          neigh_pattern = ".[%s%)]",
          register = { cr = false },
        },
        ["["] = {
          action = "open",
          pair = "[]",
          neigh_pattern = ".[%s%)}%]]",
          register = { cr = false },
        },
        ["{"] = {
          action = "open",
          pair = "{}",
          neigh_pattern = ".[%s%)}%]]",
          register = { cr = false },
        },
        [")"] = {
          action = "close",
          pair = "()",
          neigh_pattern = "[^\\%s].",
        },
        ["]"] = {
          action = "close",
          pair = "[]",
          neigh_pattern = "[^\\%s].",
        },
        ["}"] = {
          action = "close",
          pair = "{}",
          neigh_pattern = "[^\\%s].",
        },
        ['"'] = {
          action = "closeopen",
          pair = '""',
          neigh_pattern = "[^%w\\][^%w]",
          register = { cr = false },
        },
        ["'"] = {
          action = "closeopen",
          pair = "''",
          neigh_pattern = "[^%w\\][^%w]",
          register = { cr = false },
        },
        ["`"] = {
          action = "closeopen",
          pair = "``",
          neigh_pattern = "[^%w\\][^%w]",
          register = { cr = false },
        },
      },
    },
  },

  {
    "echasnovski/mini.splitjoin",
    keys = {
      {
        "gS",
        function()
          require("mini.splitjoin").toggle()
        end,
        desc = "split/join",
      },
    },
    config = function(_, _)
      require("mini.splitjoin").setup({
        mappings = {
          toggle = "",
        },
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
    end,
  },

  {
    "echasnovski/mini.statusline",
    dependencies = {
      {
        "echasnovski/mini.icons",
      },
      {
        "echasnovski/mini-git",
        name = "mini.git",
      },
      {
        "echasnovski/mini.diff",
      },
    },
    event = "UIEnter",
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
                vim.b.minigit_summary and vim.b.minigit_summary.head_name and " " .. vim.b.minigit_summary.head_name
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
              strings = {
                "%p%%/%L",
              },
            },
            { hl = mode_hl, strings = { "%l:%v" } },
          })
        end,
      },
    },
  },

  {
    "echasnovski/mini.surround",
    event = "VeryLazy",
    opts = {
      search_method = "cover_or_next",
      silent = true,
    },
  },

  {
    "echasnovski/mini.tabline",
    dependencies = {
      {
        "echasnovski/mini.icons",
      },
    },
    event = "UIEnter",
    opts = {
      tabpage_section = "right",
      format = function(buf_id, label)
        local suffix = ""
        if vim.bo[buf_id].modified then
          suffix = "● "
        elseif vim.bo[buf_id].readonly then
          suffix = " "
        end
        return MiniTabline.default_format(buf_id, label) .. suffix
      end,
    },
  },

  {
    "echasnovski/mini.visits",
    event = "VeryLazy",
    opts = {},
  },

  {
    "folke/noice.nvim",
    main = "noice",
    event = "VeryLazy",
    keys = {
      {
        "<leader>n",
        function()
          require("noice").cmd("history")
        end,
        desc = "show message history",
      },
    },
    dependencies = {
      { "MunifTanjim/nui.nvim" },
    },
    opts = {
      lsp = {
        hover = {
          silent = true,
        },
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
        signature = {
          enabled = false,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
      },
      views = {
        mini = {
          timeout = 3000,
        },
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            kind = "",
            find = "bytes",
          },
          opts = { skip = true },
        },
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
      },
    },
  },

  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "debugloop/layers.nvim",
        dev = false,
        opts = {},
      },
      {
        "igorlfs/nvim-dap-view",
        opts = {
          winbar = {
            sections = { "watches", "breakpoints", "threads", "repl" },
          },
          windows = {
            terminal = {
              hide = { "go" },
              start_hidden = true,
            },
          },
        },
      },
    },
    keys = {
      {
        "<leader>d",
        function()
          local dap = require("dap")
          if dap.session() ~= nil then
            DEBUG_MODE:activate()
            return
          end
          -- set breakpoint if there is none
          if #require("dap.breakpoints").to_qf_list(require("dap.breakpoints").get()) == 0 then
            dap.toggle_breakpoint()
          end
          -- if we're in a test file, run in test mode
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
              -- if we can't find a specific one we could run the whole test file:
              dap.run(dap.configurations.go[1])
            end
            return
          end
          -- try to restart a session
          dap.run_last()
          if dap.session() ~= nil then
            return
          end
          -- lastly, just ask
          dap.continue()
        end,
        desc = "auto launch (preference: test function > test file > last > ask)",
      },
      {
        "<leader>D",
        function()
          require("dap").continue()
        end,
        desc = "continue or start fresh session",
      },
      {
        "<leader>qb",
        function()
          require("dap").list_breakpoints()
          vim.cmd.cwindow()
        end,
        desc = "list breakpoints",
      },
      {
        "<leader>b",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "toggle breakpoint",
      },
      {
        "<leader>B",
        function()
          require("dap").clear_breakpoints()
        end,
        desc = "clear all breakpoints",
      },
    },
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
            connect = {
              host = "127.0.0.1",
              port = "2345",
            },
          },
        },
      },
    },
    config = function(_, opts)
      -- do the actual setup
      local dap = require("dap")
      dap.adapters = opts.adapters
      dap.configurations = opts.configurations
      -- ui tweaks
      vim.fn.sign_define("DapBreakpoint", { text = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "" })
      vim.fn.sign_define("DapStopped", {
        text = "",
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
      dap.listeners.after.event_initialized["hide-dap-view-buf"] = function()
        vim.api.nvim_set_option_value("buflisted", false, { buf = require("dap-view.state").term_bufnr })
      end
      -- debug mode map overlay
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
          { -- open dap-view
            "e",
            function()
              require("dap-view").toggle(true)
            end,
            { desc = "open dap-view" },
          },
          { -- step over/next
            "s",
            function()
              dap.step_over()
            end,
            { desc = "step forward" },
          },
          { -- step back
            "S",
            function()
              dap.step_back()
            end,
            { desc = "step backward" },
          },
          { -- open thread select
            "t",
            function()
              require("dap.ui.widgets").centered_float(require("dap.ui.widgets").threads)
            end,
            { desc = "threads" },
          },
          { -- open scope view
            "v",
            function()
              require("dap.ui.widgets").centered_float(require("dap.ui.widgets").scopes)
            end,
            { desc = "variables" },
          },
          { -- hover with value
            "J",
            function()
              require("dap.ui.widgets").centered_float(require("dap.ui.widgets").expression)
            end,
            { desc = "hover value" },
          },
          { -- toggle breakpoint
            "b",
            function()
              dap.toggle_breakpoint()
            end,
            { desc = "toggle breakpoint" },
          },
          { -- set conditional breakpoint
            "B",
            function()
              local cond = vim.fn.input("Breakpoint condition: ")
              dap.set_breakpoint(cond, nil, nil)
            end,
            { desc = "conditional break" },
          },
          { -- continue
            "c",
            function()
              dap.continue()
            end,
            { desc = "continue" },
          },
          { -- reverse continue
            "C",
            function()
              dap.reverse_continue()
            end,
            { desc = "reverse continue" },
          },
          { -- run to cursor
            ".",
            function()
              dap.run_to_cursor()
            end,
            { desc = "run to cursor" },
          },
          { -- step into
            "i",
            function()
              dap.step_into()
            end,
            { desc = "step into" },
          },
          { -- step out of
            "o",
            function()
              dap.step_out()
            end,
            { desc = "step out" },
          },
          { -- down one frame
            "d",
            function()
              dap.down()
            end,
            { desc = "frame down" },
          },
          { -- up one frame
            "u",
            function()
              dap.up()
            end,
            { desc = "frame up" },
          },
          { -- open frame select
            "f",
            function()
              require("dap.ui.widgets").centered_float(require("dap.ui.widgets").frames)
            end,
            { desc = "frames" },
          },
          { -- exit debug mode
            "<esc>",
            function()
              DEBUG_MODE:deactivate()
            end,
            { desc = "exit" },
          },
          { -- restart
            "r",
            function()
              dap.restart()
            end,
            { desc = "restart" },
          },
          { -- quit
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
          { -- quit and clear breakpoints
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
    end,
  },

  {
    "mfussenegger/nvim-lint",
    event = "BufWritePre",
    opts = {
      bash = { "shellcheck" },
      go = { "golangcilint" },
      markdown = { "proselint" },
      text = { "proselint" },
      nix = { "nix" },
      -- yaml = { "yamllint" },
    },
    config = function(_, opts)
      require("lint").linters_by_ft = opts
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },

  {
    "folke/lazydev.nvim",
    ft = { "lua" },
    opts = {},
  },

  {
    "nvim-treesitter/nvim-treesitter",
    event = "BufReadPost",
    opts = {
      ensure_installed = {}, -- we get this from nix
      highlight = {
        enable = true,
      },
      incremental_selection = {
        enable = false,
        keymaps = {
          init_selection = "<cr>",
          node_incremental = "<cr>",
          scope_incremental = "<s-cr>",
          node_decremental = "<bs>",
        },
      },
      indent = {
        enable = true,
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter" },
    },
    event = "VeryLazy",
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    main = "nvim-treesitter.configs",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter" },
    },
    keys = { "gz", "gF", "gT" },
    opts = {
      textobjects = {
        lsp_interop = {
          enable = true,
          peek_definition_code = {
            ["gz"] = "@peek", -- replaces both below for go
            ["gF"] = "@function.outer",
            ["gT"] = "@class.outer",
          },
        },
        swap = {
          enable = false, -- not needed
        },
        select = {
          enable = false, -- done with mini.ai
        },
        move = {
          enable = false, -- done with mini.ai and impairative
        },
      },
    },
  },

  {
    "folke/snacks.nvim",
    -- picker stuff from snacks
    lazy = false,
    keys = {
      -- restore lsp lookup quickfix
      {
        "<leader><leader>",
        function()
          Snacks.picker.qflist({
            focus = "list",
            layout = "bqflike",
          })
        end,
        desc = "open quickfix",
      },
      -- spelling
      {
        "z=",
        function()
          require("snacks").picker.spelling({
            focus = "list",
          })
        end,
        desc = "spell suggest",
      },
      -- tree explorer
      {
        "-",
        function()
          Snacks.picker.explorer({
            focus = "list",
          })
        end,
        desc = "Tree",
      },
      -- undo
      {
        "<leader>u",
        function()
          Snacks.picker.undo({
            focus = "list",
          })
        end,
        desc = "Undo",
      },
      -- open or select important things
      {
        "<leader>f",
        function()
          require("snacks").picker.files()
        end,
        desc = "find files",
      },
      {
        "<leader>F",
        function()
          require("snacks").picker.smart()
        end,
        desc = "find more files smartly",
      },
      {
        "<leader>,",
        function()
          Snacks.picker.buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>:",
        function()
          Snacks.picker.command_history({
            focus = "list",
          })
        end,
        desc = "Command History",
      },
      -- grep
      {
        "<leader>/",
        function()
          Snacks.picker.grep()
        end,
        desc = "Grep",
      },
      {
        "<leader>*",
        mode = { "n", "x" },
        function()
          require("snacks").picker.grep_word({
            focus = "list",
          })
        end,
        desc = "grep word",
      },
      -- search
      {
        '<leader>s"',
        function()
          Snacks.picker.registers()
        end,
        desc = "Registers",
      },
      {
        "<leader>sa",
        function()
          Snacks.picker.autocmds()
        end,
        desc = "Autocmds",
      },
      {
        "<leader>sc",
        function()
          require("snacks").picker.cliphist({
            focus = "list",
          })
        end,
        desc = "Cliphist",
      },
      {
        "<leader>sd",
        function()
          Snacks.picker.diagnostics({
            focus = "list",
          })
        end,
        desc = "Diagnostics",
      },
      {
        "<leader>sh",
        function()
          Snacks.picker.help()
        end,
        desc = "Help Pages",
      },
      {
        "<leader>sH",
        function()
          Snacks.picker.highlights()
        end,
        desc = "Highlights",
      },
      {
        "<leader>si",
        function()
          Snacks.picker.icons()
        end,
        desc = "Icons",
      },
      {
        "<leader>sk",
        function()
          Snacks.picker.keymaps()
        end,
        desc = "Keymaps",
      },
      {
        "<leader>sl",
        function()
          Snacks.picker.loclist({
            focus = "list",
          })
        end,
        desc = "Location List",
      },
      {
        "<leader>sM",
        function()
          Snacks.picker.man()
        end,
        desc = "Man Pages",
      },
      {
        "<leader>sm",
        function()
          Snacks.picker.marks()
        end,
        desc = "Marks",
      },
      -- lsp overrides
      {
        "go",
        function()
          Snacks.picker.treesitter({
            focus = "list",
          })
        end,
        desc = "treesitter: show symbols",
      },
      {
        "<leader>sr",
        function()
          Snacks.picker.resume({
            focus = "list",
          })
        end,
        desc = "Resume",
      },
      {
        "go",
        function()
          Snacks.picker.lsp_symbols({
            focus = "list",
            layout = "bqflike",
          })
        end,
        { desc = "lsp: show symbols" },
      },
      {
        "gO",
        function()
          Snacks.picker.lsp_workspace_symbols({
            focus = "list",
            layout = "bqflike",
          })
        end,
        { desc = "lsp: show all symbols" },
      },
      {
        "gd",
        function()
          Snacks.picker.lsp_definitions({
            focus = "list",
            layout = "bqflike",
            on_show = PickerQF,
          })
        end,
        { desc = "lsp: show definition" },
      },
      {
        "gD",
        function()
          Snacks.picker.lsp_type_definitions({
            focus = "list",
            layout = "bqflike",
            on_show = PickerQF,
          })
        end,
        { desc = "lsp: show type definition" },
      },
      {
        "gi",
        function()
          Snacks.picker.lsp_implementations({
            focus = "list",
            layout = "bqflike",
            on_show = PickerQF,
          })
        end,
        { desc = "lsp: show implementations" },
      },
      {
        "gr",
        function()
          Snacks.picker.lsp_references({
            focus = "list",
            layout = "bqflike",
            on_show = PickerQF,
          })
        end,
        { desc = "lsp: show refs" },
      },
    },
    init = function()
      function PickerQF(picker)
        local qf = {}
        for _, item in ipairs(picker:items()) do
          qf[#qf + 1] = {
            filename = Snacks.picker.util.path(item),
            bufnr = item.buf,
            lnum = item.pos and item.pos[1] or 1,
            col = item.pos and item.pos[2] + 1 or 1,
            end_lnum = item.end_pos and item.end_pos[1] or nil,
            end_col = item.end_pos and item.end_pos[2] + 1 or nil,
            text = item.line or item.comment or item.label or item.name or item.detail or item.text,
            pattern = item.search,
            valid = true,
          }
        end
        vim.fn.setqflist(qf)
      end
    end,
    config = function(_, opts)
      require("snacks").setup(opts)
    end,
    opts = {
      picker = {
        layout = {
          preset = function()
            return vim.o.columns >= 120 and "ivy" or "vertical"
          end,
        },
        layouts = {
          bqflike = {
            layout = {
              box = "vertical",
              backdrop = true,
              row = -1,
              width = 0,
              height = 0.5,
              border = "top",
              title = " {source}",
              title_pos = "left",
              {
                win = "preview",
                height = 0.6,
              },
              {
                win = "list",
                border = "top",
              },
              {
                win = "input",
                height = 1,
                border = "none",
              },
            },
          },
        },
        ui_select = true,
        win = {
          input = {
            keys = {
              ["<Esc>"] = { "toggle_focus", mode = { "i" } },
              -- unmap
              ["<a-d>"] = nil,
              ["<a-h>"] = nil,
              ["<a-i>"] = nil,
              -- replace
              ["<a-m>"] = nil,
              ["<c-m>"] = { "toggle_maximize", mode = { "i", "n" } },
              ["<a-p>"] = nil,
              ["<c-p>"] = { "toggle_preview", mode = { "i", "n" } },
              ["<a-w>"] = nil,
              ["<c-space>"] = "cycle_win",
            },
          },
          list = {
            keys = {
              -- unmap
              ["<a-d>"] = nil,
              ["<a-f>"] = nil,
              ["<a-h>"] = nil,
              ["<a-i>"] = nil,
              -- replace
              ["<a-m>"] = nil,
              ["<c-m>"] = "toggle_maximize",
              ["<a-p>"] = nil,
              ["<c-p>"] = "toggle_preview",
              ["<a-w>"] = nil,
              ["<c-space>"] = "cycle_win",
            },
          },
          preview = {
            keys = {
              -- replace
              ["<a-w>"] = nil,
              ["<c-space>"] = "cycle_win",
            },
          },
        },
      },
    },
  },

  {
    "folke/snacks.nvim",
    -- git stuff from snacks
    lazy = false,
    dependencies = {
      {
        "echasnovski/mini-git",
        name = "mini.git",
      },
    },
    keys = {
      {
        "<leader>gb",
        mode = { "n" },
        function()
          require("snacks").picker.git_log_line()
        end,
        desc = "Show Git Blame",
      },
      {
        "gy",
        mode = { "n", "x" },
        function()
          require("snacks").gitbrowse({
            branch = MiniGit.get_buf_data(0).head,
          })
        end,
        desc = "Copy Git URL",
      },
      {
        "<leader>gl",
        function()
          Snacks.picker.git_log()
        end,
        desc = "Git Log",
      },
      {
        "<leader>gs",
        function()
          Snacks.picker.git_status()
        end,
        desc = "Git Status",
      },
    },
    opts = {
      gitbrowse = {
        notify = false,
        open = function(url)
          vim.fn.setreg("+", url, "v")
        end,
      },
    },
  },

  {
    "idanarye/nvim-impairative",
    event = "VeryLazy",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter" },
      { "echasnovski/mini.ai" },
    },
    config = function(_, _)
      vim.keymap.set("n", "]", "<nop>", { desc = "+forward goto " })
      vim.keymap.set("n", "[", "<nop>", { desc = "+backward goto" })
      local base = require("impairative").operations({
        backward = "[",
        forward = "]",
      })
      for key, obj in pairs({
        a = {
          name = "arguments",
          scope = "i",
          reverse = false,
          textobject = "a",
        },
        A = {
          name = "argmuments",
          scope = "i",
          reverse = true,
          textobject = "a",
        },
        b = {
          name = "braces",
          scope = "i",
          reverse = false,
          textobject = "b",
        },
        B = {
          name = "blocks",
          scope = "i",
          reverse = false,
          textobject = "B",
        },
        s = {
          name = "strings",
          scope = "i",
          reverse = false,
          textobject = "s",
        },
        S = {
          name = "strings",
          scope = "i",
          reverse = true,
          textobject = "s",
        },
        f = {
          name = "functions",
          scope = "a",
          reverse = false,
          textobject = "f",
        },
        F = {
          name = "functions",
          scope = "a",
          reverse = true,
          textobject = "f",
        },
        c = {
          name = "calls",
          scope = "a",
          reverse = false,
          textobject = "c",
        },
        C = {
          name = "calls",
          scope = "i",
          reverse = true,
          textobject = "c",
        },
        i = {
          name = "ifs",
          scope = "a",
          reverse = false,
          textobject = "i",
        },
        I = {
          name = "ifs",
          scope = "a",
          reverse = true,
          textobject = "i",
        },
        L = {
          name = "loops",
          scope = "a",
          reverse = false,
          textobject = "L",
        },
        t = {
          name = "types",
          scope = "a",
          reverse = false,
          textobject = "t",
        },
      }) do
        local edge = "left"
        local target = "beginning"
        local dirmap = {
          backward = "cover_or_prev",
          forward = "next",
        }
        if obj.reverse then
          edge = "right"
          target = "end"
          dirmap = {
            backward = "prev",
            forward = "cover_or_next",
          }
        end
        base:unified_function({
          key = key,
          desc = "jump to " .. target .. " of '" .. obj.textobject .. "' textobject",
          fun = function(direction)
            require("mini.ai").move_cursor(
              edge,
              obj.scope,
              obj.textobject,
              { search_method = dirmap[direction], n_times = vim.v.count1 }
            )
          end,
        })
      end
    end,
  },

  {
    "folke/snacks.nvim",
    -- other stuff from snacks
    lazy = false,
    keys = {
      {
        "]]",
        function()
          Snacks.words.jump(vim.v.count1, true)
        end,
      },
      {
        "[[",
        function()
          Snacks.words.jump(-vim.v.count1, true)
        end,
      },
      {
        "<leader>ob",
        function()
          Snacks.toggle
            .option("background", {
              on = "light",
              off = "dark",
            })
            :toggle()
        end,
        desc = "toggle background",
      },
      {
        "<leader>oc",
        function()
          Snacks.toggle
            .new({
              id = "tscontext",
              name = "treesitter context",
              get = function()
                return require("treesitter-context").enabled()
              end,
              set = function(_)
                require("treesitter-context").toggle()
              end,
            })
            :toggle()
        end,
        desc = "toggle context",
      },
      {
        "<leader>od",
        function()
          Snacks.toggle.diagnostics():toggle()
        end,
        desc = "toggle diagnostics",
      },
      {
        "<leader>oD",
        function()
          Snacks.toggle.dim():toggle()
        end,
        desc = "toggle dimming",
      },
      {
        "<leader>oh",
        function()
          Snacks.toggle.inlay_hints():toggle()
        end,
        desc = "toggle inlay hints",
      },
      {
        "<leader>oi",
        function()
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
        end,
        desc = "toggle indentscope",
      },
      {
        "<leader>oI",
        function()
          Snacks.toggle.words():toggle()
        end,
        desc = "toggle illumination",
      },
      {
        "<leader>ol",
        function()
          Snacks.toggle.option("list"):toggle()
        end,
        desc = "toggle list",
      },
      {
        "<leader>on",
        function()
          Snacks.toggle.option("number"):toggle()
        end,
        desc = "toggle number",
      },
      {
        "<leader>op",
        function()
          Snacks.toggle
            .new({
              id = "pairs",
              name = "pairs",
              get = function()
                return not vim.g.minipairs_disable
              end,
              set = function(state)
                vim.g.minipairs_disable = not state
              end,
            })
            :toggle()
        end,
        desc = "toggle auto pairs",
      },
      {
        "<leader>or",
        function()
          Snacks.toggle.option("relativenumber"):toggle()
        end,
        desc = "toggle relativenumber",
      },
      {
        "<leader>os",
        function()
          Snacks.toggle.scroll():toggle()
        end,
        desc = "toggle smooth scroll",
      },
      {
        "<leader>oS",
        function()
          Snacks.toggle.option("spell"):toggle()
        end,
        desc = "toggle spell",
      },
      {
        "<leader>ot",
        function()
          Snacks.toggle.treesitter():toggle()
        end,
        desc = "toggle treesitter",
      },
      {
        "<leader>ov",
        function()
          local toggle = Snacks.toggle.get("virtualedit")
          if not toggle then
            toggle = Snacks.toggle.new({
              id = "virtualedit",
              name = "virtualedit",
              get = function()
                return vim.o.virtualedit == "all"
              end,
              set = function(state)
                if state then
                  vim.opt.virtualedit = "all"
                else
                  vim.opt.virtualedit = "block"
                end
              end,
            })
          end
          toggle:toggle()
        end,
        desc = "toggle virtualedit",
      },
      {
        "<leader>ow",
        function()
          Snacks.toggle.option("wrap"):toggle()
        end,
        desc = "toggle wrap",
      },
      {
        "<leader>ox",
        function()
          Snacks.toggle.option("cursorcolumn"):toggle()
        end,
        desc = "toggle cursorcolumn",
      },
      {
        "<leader>oz",
        function()
          Snacks.toggle.zen():toggle()
        end,
        desc = "toggle zen mode",
      },
    },
    config = function(_, opts)
      require("snacks").setup(opts)
      vim.print = require("snacks").debug.inspect
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesActionRename",
        callback = function(event)
          require("snacks").rename.on_rename_file(event.data.from, event.data.to)
        end,
      })
    end,
    opts = {
      bigfile = { enabled = true },
      input = { enabled = true },
      image = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      scroll = {
        enabled = true,
        animate = {
          duration = { step = 15, total = 150 },
        },
      },
      statuscolumn = { enabled = true },
      styles = {
        notification = {
          wo = { wrap = true },
        },
        zen = {
          backdrop = {
            transparent = false,
          },
        },
      },
      toggle = {
        which_key = false,
      },
      words = { enabled = true },
    },
  },

  {
    "debugloop/telescope-undo.nvim",
    enabled = false,
    dev = true,
    dependencies = {
      {
        "nvim-telescope/telescope.nvim",
        config = function() end,
        dependencies = {
          { "nvim-lua/plenary.nvim" },
        },
      },
    },
    keys = {
      {
        "<leader>u",
        "<cmd>Telescope undo<cr>",
        desc = "undo history",
      },
    },
    opts = {
      defaults = {
        mappings = {
          n = {
            ["q"] = function(bufnr)
              return require("telescope.actions").close(bufnr)
            end,
            ["<esc>"] = function(bufnr)
              return require("telescope.actions").close(bufnr)
            end,
          },
          i = {
            ["<c-j>"] = function(bufnr)
              return require("telescope.actions").move_selection_next(bufnr)
            end,
            ["<c-k>"] = function(bufnr)
              return require("telescope.actions").move_selection_previous(bufnr)
            end,
          },
        },
      },
      extensions = {
        undo = {
          side_by_side = true,
          layout_strategy = "vertical",
          vim_diff_opts = {
            algorithm = "histogram",
            ctxlen = 6,
          },
          layout_config = {
            preview_height = 0.8,
          },
        },
      },
    },
    config = function(_, opts)
      require("telescope").setup(opts)
      require("telescope").load_extension("undo")
    end,
  },
})
