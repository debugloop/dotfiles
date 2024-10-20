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
    local nixpkgs_dir = vim.fn.stdpath("data") .. "/nixpkgs/" .. plugin_name:gsub("%.", "-")
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
    "saghen/blink.cmp",
    lazy = false, -- it handles itself and is an integral part anyhow
    -- enabled = false,
    dependencies = {
      { "rafamadriz/friendly-snippets" },
    },
    opts = {
      keymap = {
        show = "<c-space>",
        hide = "<c-e>",
        accept = "<cr>",
        select_and_accept = "<cr>",
        select_prev = { "<s-tab>", "<up>", "<c-p>" },
        select_next = { "<tab>", "<down>", "<c-n>" },

        show_documentation = "<c-space>",
        hide_documentation = "<c-space>",
        scroll_documentation_up = "<c-u>",
        scroll_documentation_down = "<c-d>",

        snippet_forward = "<tab>",
        snippet_backward = "<s-tab>",
      },
      accept = {
        auto_brackets = {
          enabled = true,
        },
      },
      windows = {
        autocomplete = {
          selection = "auto_insert",
          max_height = 16,
        },
        documentation = {
          auto_show = true,
          max_width = 82,
          max_height = 16,
        },
      },
      highlight = {
        use_nvim_cmp_as_default = true,
      },
      nerd_font_variant = "mono",
      sources = {
        providers = {
          { "blink.cmp.sources.lsp", name = "LSP" },
          { "blink.cmp.sources.path", name = "Path" },
          { "blink.cmp.sources.snippets", name = "Snippets", score_offset = -3 },
        },
      },
      kind_icons = {
        Class = "󰠱",
        Color = "󰏘",
        Constant = "󰏿",
        Constructor = "󰒓",
        Enum = "",
        EnumMember = "",
        Event = "󱐋",
        Field = "󰇽",
        File = "󰈔",
        Folder = "󰉋",
        Function = "󰊕",
        Interface = "",
        Keyword = "󰌋",
        Method = "󰆧",
        Module = "󰅩",
        Operator = "󰆕",
        Property = "󰜢",
        Reference = "",
        Snippet = "",
        Struct = "",
        Text = "󰉿",
        TypeParameter = "󰅲",
        Unit = "",
        Value = "󰎠",
        Variable = "󰂡",
      },
    },
  },

  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        go = { "gofumpt", "goimports", "goimports-reviser" },
        javascript = { "prettier" },
        lua = { "stylua" },
        nix = { "alejandra" },
        ["*"] = function(bufnr)
          if vim.fn.getbufvar(bufnr, "&filetype") == "terraform" then
            return {}
          end
          return { "trim_whitespace" }
        end,
      },
      format_on_save = {
        lsp_fallback = true,
        timeout_ms = 5000,
      },
      formatters = {
        prettier = {
          prepend_args = { "--tab-width", "4" },
        },
      },
    },
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },

  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "PRDiff", "PRLog" },
    opts = {
      default_args = {
        DiffviewOpen = { "--imply-local" },
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
      vim.api.nvim_create_user_command("PRDiff", function()
        vim.cmd("DiffviewOpen origin/HEAD...HEAD --untracked-files=no --imply-local")
      end, { desc = "open diffview for current PR" })
      vim.api.nvim_create_user_command("PRLog", function()
        vim.cmd("DiffviewFileHistory --range=origin/HEAD...HEAD --base=LOCAL --right-only --no-merges")
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
        return {
          -- dark completion
          Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },
          PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
          PmenuSbar = { bg = theme.ui.bg_m1 },
          PmenuThumb = { bg = theme.ui.bg_p2 },
          -- nvim-tree
          NvimTreeNormal = { bg = theme.ui.bg_dim },
          NvimTreeGitDirty = { fg = theme.term[5], bg = "none" },
          NvimTreeGitStaged = { fg = theme.term[4], bg = "none" },
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
          BqfPreviewTitle = { link = "BqfPreviewBorder" },
        }
      end,
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = "none",
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
      mappings = {
        around_last = "aN",
        inside_last = "iN",
      },
      n_lines = 200,
    },
    config = function(_, opts)
      opts.custom_textobjects = {
        -- arg
        a = require("mini.ai").gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),
        -- braces
        b = { { "%b()", "%b[]", "%b{}" }, "^.().*().$" },
        -- block
        B = require("mini.ai").gen_spec.treesitter({ a = "@block.outer", i = { "@customblock.inner", "@block.inner" } }),
        -- call
        c = require("mini.ai").gen_spec.treesitter({ a = "@call.outer", i = "@call.inner" }),
        -- function / method
        f = require("mini.ai").gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
        -- if
        i = require("mini.ai").gen_spec.treesitter({
          a = "@conditional.outer",
          i = { "@customconditional.inner", "@conditional.inner" },
        }),
        -- loop
        l = require("mini.ai").gen_spec.treesitter({ a = "@loop.outer", i = { "@customloop.inner", "@loop.inner" } }),
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
    "echasnovski/mini.completion",
    enabled = false,
    lazy = false,
    dependencies = {
      {
        "echasnovski/mini.icons",
      },
      {
        "echasnovski/mini.fuzzy",
        opts = {},
      },
    },
    keys = {
      {
        "<tab>",
        [[pumvisible() ? "\<c-n>" : "\<tab>"]],
        mode = "i",
        expr = true,
      },
      {
        "<s-tab>",
        [[pumvisible() ? "\<c-p>" : "\<s-tab>"]],
        mode = "i",
        expr = true,
      },
    },
    opts = {
      delay = {
        signature = 10 ^ 7,
      },
    },
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
          { mode = "n", keys = "<leader>M" },
          { mode = "x", keys = "<leader>M" },
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
          -- custom
          { mode = "n", keys = "p" },
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
          -- maps that don't quit move mode
          { mode = "n", keys = "<leader>Mh", postkeys = "<leader>M" },
          { mode = "n", keys = "<leader>Mj", postkeys = "<leader>M" },
          { mode = "n", keys = "<leader>Mk", postkeys = "<leader>M" },
          { mode = "n", keys = "<leader>Ml", postkeys = "<leader>M" },
          { mode = "x", keys = "<leader>Mh", postkeys = "<leader>M" },
          { mode = "x", keys = "<leader>Mj", postkeys = "<leader>M" },
          { mode = "x", keys = "<leader>Mk", postkeys = "<leader>M" },
          { mode = "x", keys = "<leader>Ml", postkeys = "<leader>M" },
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
    "echasnovski/mini.git",
    keys = {
      {
        "<leader>gi",
        mode = { "n", "x" },
        function()
          require("mini.git").show_at_cursor()
        end,
        desc = "Show Git info",
      },
      {
        "<leader>gb",
        function()
          vim.cmd("vertical Git blame -- %")
        end,
        desc = "Show git blame",
      },
    },
    opts = {},
    config = function(_, opts)
      require("mini.git").setup(opts)
      local align_blame = function(au_data)
        if au_data.data.git_subcommand ~= "blame" then
          return
        end
        -- Align blame output with source
        local win_src = au_data.data.win_source
        vim.wo.wrap = false
        vim.fn.winrestview({ topline = vim.fn.line("w0", win_src) - 1 })
        vim.api.nvim_win_set_cursor(0, { vim.fn.line(".", win_src), 0 })
        -- Bind both windows so that they scroll together
        vim.wo[win_src].scrollbind, vim.wo.scrollbind = true, true
        vim.wo[win_src].cursorbind, vim.wo.cursorbind = true, true
      end
      vim.api.nvim_create_autocmd("User", {
        group = vim.api.nvim_create_augroup("mini_git", { clear = true }),
        pattern = "MiniGitCommandSplit",
        callback = align_blame,
      })
    end,
  },

  {
    "echasnovski/mini.hipatterns",
    event = "VeryLazy",
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
        -- do not auto create a pair when in front of word chars
        ["("] = { action = "open", pair = "()", neigh_pattern = "[^\\][^%w]" },
        ["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\][^%w]" },
        ["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\][^%w]" },
        -- do not swallow closing brackets when after a space chars
        [")"] = { action = "close", pair = "()", neigh_pattern = "[^\\%s]." },
        ["]"] = { action = "close", pair = "[]", neigh_pattern = "[^\\%s]." },
        ["}"] = { action = "close", pair = "{}", neigh_pattern = "[^\\%s]." },
        -- we use the default close actions
        ['"'] = { action = "closeopen", pair = '""', neigh_pattern = "[^\\][%s%)%]}]", register = { cr = false } },
        ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%a\\][%s%)%]}]", register = { cr = false } },
        ["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^\\][%s%)%]}]", register = { cr = false } },
      },
    },
  },

  {
    "echasnovski/mini.pick",
    event = "VeryLazy", -- for overriding vim.ui.select at startup
    dependencies = {
      {
        "echasnovski/mini.extra",
      },
    },
    keys = {
      {
        "<leader>f",
        function()
          require("mini.pick").builtin.files()
        end,
        desc = "find files",
      },
      {
        "<leader>F",
        function()
          require("mini.extra").pickers.visit_paths()
        end,
        desc = "find in visits",
      },
      {
        "<leader>m",
        function()
          require("mini.extra").pickers.marks({ scope = "global" }, {})
        end,
        desc = "find in marks",
      },
      {
        "<leader>T",
        function()
          require("mini.extra").pickers.hipatterns()
        end,
        desc = "find in TODOs",
      },
      {
        "z=",
        function()
          require("mini.extra").pickers.spellsuggest()
        end,
        desc = "spell suggest",
      },
    },
    opts = {
      mappings = {
        move_up = "<c-k>",
        move_down = "<c-j>",
      },
    },
    config = function(_, opts)
      require("mini.pick").setup(opts)
      vim.ui.select = require("mini.pick").ui_select
    end,
  },

  {
    "echasnovski/mini.splitjoin",
    keys = { "gS" },
    config = function(_, _)
      require("mini.splitjoin").setup({
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
        "echasnovski/mini.git",
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
    keys = { "s" },
    opts = {
      search_method = "cover_or_next",
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
      presets = {
        bottom_search = true,
        command_palette = true,
      },
      popupmenu = {
        enabled = false,
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
      },
    },
  },

  {
    "stevearc/quicker.nvim",
    event = "VeryLazy",
    opts = {
      opts = {
        winfixheight = false,
      },
      on_qf = function(bufnr) end,
      keys = {
        {
          "q",
          function()
            vim.cmd.q()
            if not require("bqf.preview.handler").autoEnabled() then
              require("bqf.preview.handler").toggle()
            end
          end,
          desc = "Close Quickfix",
        },
        {
          ">",
          function()
            vim.cmd("wincmd =")
            if require("bqf.preview.handler").autoEnabled() then
              require("bqf.preview.handler").toggle()
            end
            require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
          end,
          desc = "Expand quickfix context",
        },
        {
          "<",
          function()
            vim.cmd("copen 10")
            if not require("bqf.preview.handler").autoEnabled() then
              require("bqf.preview.handler").toggle()
            end
            require("quicker").collapse()
          end,
          desc = "Collapse quickfix context",
        },
        {
          "J",
          function()
            local items = vim.fn.getqflist()
            local lnum = vim.api.nvim_win_get_cursor(0)[1]
            for i = lnum + 1, #items do
              if items[i].valid == 1 then
                vim.api.nvim_win_set_cursor(0, { i, 0 })
                return
              end
            end
            -- Wrap around the end of quickfix list
            for i = 1, lnum do
              if items[i].valid == 1 then
                vim.api.nvim_win_set_cursor(0, { i, 0 })
                return
              end
            end
          end,
        },
        {
          "K",
          function()
            local items = vim.fn.getqflist()
            local lnum = vim.api.nvim_win_get_cursor(0)[1]
            for i = lnum - 1, 1, -1 do
              if items[i].valid == 1 then
                vim.api.nvim_win_set_cursor(0, { i, 0 })
                return
              end
            end
            -- Wrap around the start of quickfix list
            for i = #items, lnum, -1 do
              if items[i].valid == 1 then
                vim.api.nvim_win_set_cursor(0, { i, 0 })
                return
              end
            end
          end,
        },
      },
    },
  },

  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    dependencies = {
      {
        "junegunn/fzf",
        dir = vim.fn.stdpath("data") .. "/nixpkgs/fzf",
        name = "fzf",
        build = "./install --all",
      },
      {
        "stevearc/quicker.nvim",
      },
    },
    opts = {
      func_map = {
        open = "",
        openc = "<cr>",
        drop = "",
        split = "<C-x>",
        vsplit = "<C-v>",
        tab = "",
        tabb = "",
        tabc = "",
        tabdrop = "",
        ptogglemode = "<tab>",
        ptoggleitem = "",
        ptoggleauto = "",
        pscrollup = "",
        pscrolldown = "",
        pscrollorig = "zz",
        prevfile = "",
        nextfile = "",
        prevhist = "<C-p>",
        nexthist = "<C-n>",
        lastleave = "",
        stoggleup = "",
        stoggledown = "",
        stogglevm = "",
        stogglebuf = "",
        sclear = "",
        filter = "",
        filterr = "",
        fzffilter = "f",
      },
      filter = {
        fzf = {
          action_for = {},
          extra_opts = { "--multi", "--bind", "enter:toggle-all+accept" },
        },
      },
      preview = {
        winblend = 0,
        border = "single",
      },
    },
  },

  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "debugloop/layers.nvim",
        dev = true,
        opts = {},
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
        desc = "auto launch (preference: test function > last > ask)",
      },
      {
        "<leader>D",
        function()
          require("dap").continue()
        end,
        desc = "continue or start fresh session",
      },
      {
        "gb",
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
            mode = "test",
            program = "./${relativeFileDirname}",
            buildFlags = "-tags=unit,integration,e2e",
          },
          {
            type = "go",
            name = "main",
            request = "launch",
            program = "${fileDirname}",
          },
          {
            type = "go",
            name = "main (with args)",
            request = "launch",
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
            processId = function()
              return require("dap.utils").pick_process()
            end,
          },
          {
            type = "go",
            name = "remote",
            mode = "remote",
            request = "attach",
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
      vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "", linehl = "", numhl = "" })
      -- treat dap-repl as a terminal
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("on_dap_repl", { clear = true }),
        pattern = "dap-repl",
        callback = function()
          vim.cmd("startinsert")
        end,
      })
      -- debug mode map overlay
      DEBUG_MODE = Layers.mode.new()
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
          { -- evaluate expression continuously
            "e",
            function()
              local exp = vim.fn.input("Expression: ")
              if exp == "" then
                exp = vim.fn.expand("<cexpr>")
              end
              local prefix = exp:sub(-1) == ")" and "call " or ""
              require("dap.ui.widgets").preview(prefix .. exp)
              dap.listeners.after.event_stopped["refresh_expr"] = function()
                require("dap.ui.widgets").preview(prefix .. exp)
              end
            end,
            { desc = "auto eval" },
          },
          { -- clear evaluation watch
            "E",
            function()
              dap.listeners.after.event_stopped["refresh_expr"] = nil
              vim.cmd("pclose")
            end,
            { desc = "clear auto eval" },
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
    "idanarye/nvim-impairative",
    event = "VeryLazy",
    config = function(_, _)
      -- options
      vim.keymap.set("n", "<leader>o", "<nop>", { desc = "+options" })
      vim.keymap.set("n", "]o", "<nop>", { desc = "+enable options" })
      vim.keymap.set("n", "[o", "<nop>", { desc = "+disable options" })
      require("impairative")
        .toggling({
          enable = "]o",
          disable = "[o",
          toggle = "<leader>o",
        })
        :option({
          key = "b",
          option = "background",
          values = { [true] = "dark", [false] = "light" },
        })
        :getter_setter({
          key = "d",
          name = "diagnostics",
          get = vim.diagnostic.is_enabled,
          set = vim.diagnostic.enable,
        })
        :getter_setter({
          key = "h",
          name = "inlay hints",
          get = vim.lsp.inlay_hint.is_enabled,
          set = vim.lsp.inlay_hint.enable,
        })
        :field({
          key = "H",
          name = "todo highlights",
          table = vim.g,
          field = "minihipatterns_disable",
        })
        :field({
          key = "D",
          name = "highlight usages and definitions",
          table = vim.g,
          field = "disable_highlight_defs",
        })
        :field({
          key = "i",
          name = "indentscope",
          table = vim.g,
          field = "miniindentscope_disable",
        })
        -- TODO: make highlights toggleable
        -- :manual({
        --   key = "I",
        --   name = "highlight occurences",
        --   enable = "TSBufEnable refactor.highlight_definitions",
        --   disable = "TSBufDisable refactor.highlight_definitions",
        --   toggle = "TSBufToggle refactor.highlight_definitions",
        -- })
        :option({
          key = "l",
          option = "list",
        })
        :option({
          key = "n",
          option = "number",
        })
        :field({
          key = "p",
          name = "auto pairs",
          table = vim.g,
          field = "minipairs_disable",
        })
        :option({
          key = "r",
          option = "relativenumber",
        })
        :option({
          key = "s",
          option = "spell",
        })
        :manual({
          key = "t",
          name = "show context",
          enable = "TSContextEnable",
          disable = "TSContextDisable",
          toggle = "TSContextToggle",
        })
        :option({
          key = "v",
          option = "virtualedit",
          values = { [true] = "all", [false] = "block" },
        })
        :option({
          key = "w",
          option = "wrap",
        })
        :option({
          key = "x",
          option = "cursorcolumn",
        })
      -- ts navigation of usages (adapted from nvim-treesitter-refactor)
      local function index_of(tbl, obj)
        for i, o in ipairs(tbl) do
          if o == obj then
            return i
          end
        end
      end
      local function goto_adjacent_usage(delta)
        local ts_utils = require("nvim-treesitter.ts_utils")
        local locals = require("nvim-treesitter.locals")
        local bufnr = vim.api.nvim_get_current_buf()
        local node_at_point = ts_utils.get_node_at_cursor()
        if not node_at_point then
          return
        end
        local def_node, scope = locals.find_definition(node_at_point, bufnr)
        local usages = locals.find_usages(def_node, scope, bufnr)
        local index = index_of(usages, node_at_point)
        if not index then
          return
        end
        local target_index = (index + delta + #usages - 1) % #usages + 1
        ts_utils.goto_node(usages[target_index])
      end
      -- textobject navigation
      vim.keymap.set("n", "]", "<nop>", { desc = "+forward goto " })
      vim.keymap.set("n", "[", "<nop>", { desc = "+backward goto" })
      local base = require("impairative")
        .operations({
          backward = "[",
          forward = "]",
        })
        :function_pair({
          key = "]",
          backward = function()
            goto_adjacent_usage(-vim.v.count1)
          end,
          forward = function()
            goto_adjacent_usage(vim.v.count1)
          end,
        })
        :function_pair({
          key = "[",
          backward = function()
            goto_adjacent_usage(-vim.v.count1)
          end,
          forward = function()
            goto_adjacent_usage(vim.v.count1)
          end,
        })
      for key, ia in pairs({
        a = "i",
        A = "i",
        b = "i",
        B = "i",
        s = "i",
        S = "i",
        f = "a",
        c = "a",
        i = "a",
        l = "a",
        t = "a",
      }) do
        local edge = "left"
        local target = "beginning"
        local dirmap = {
          backward = "cover_or_prev",
          forward = "next",
        }
        if key == key:upper() then
          edge = "right"
          target = "end"
          dirmap = {
            backward = "prev",
            forward = "cover_or_next",
          }
        end
        base:unified_function({
          key = key,
          desc = "jump to " .. target .. " of '" .. key:lower() .. "' textobject",
          fun = function(direction)
            require("mini.ai").move_cursor(
              edge,
              ia,
              key:lower(),
              { search_method = dirmap[direction], n_times = vim.v.count1 }
            )
          end,
        })
      end
    end,
  },

  {
    "mfussenegger/nvim-lint",
    event = "BufWritePre",
    opts = {
      bash = { "shellcheck" },
      go = { "golangcilint", "codespell" },
      -- markdown = { 'vale', 'languagetool', },
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

  -- {
  --   "yorickpeterse/nvim-pqf",
  --   event = "VeryLazy", -- needs to be loaded before qf results are generated
  --   opts = {},
  -- },

  {
    "folke/lazydev.nvim",
    ft = { "lua" },
    opts = {},
  },

  {
    "nvim-tree/nvim-tree.lua",
    keys = {
      {
        "-",
        function()
          require("nvim-tree.api").tree.toggle({ focus = false })
        end,
        desc = "toggle buffer tree",
      },
    },
    opts = {
      on_attach = function(bufnr)
        vim.keymap.set("n", "<CR>", require("nvim-tree.api").node.open.edit, {
          desc = "nvim-tree: open",
          buffer = bufnr,
          noremap = true,
          silent = true,
          nowait = true,
        })
      end,
      hijack_netrw = false,
      root_dirs = { "~", "/" },
      update_focused_file = {
        enable = true,
        update_root = true,
      },
      view = {
        width = 40,
      },
      modified = {
        enable = true,
      },
      filters = {
        no_buffer = true,
        custom = { "^.git$" },
      },
      renderer = {
        root_folder_label = ":~:s?$?",
        group_empty = true,
        indent_markers = {
          enable = true,
        },
        icons = {
          show = {
            file = false,
            folder = false,
          },
          git_placement = "signcolumn",
          glyphs = {
            git = {
              unstaged = "✚",
              staged = "●",
              unmerged = "",
              renamed = "»",
              untracked = "…",
              deleted = "✖",
              ignored = "◌",
            },
          },
        },
      },
    },
    config = function(_, opts)
      local api = require("nvim-tree.api")
      local function get_buffers()
        local current_buffer = require("nvim-tree.api").tree.get_node_under_cursor().absolute_path
        local pos = 0
        local bufferlist = {}
        local function procNode(node)
          if node.type ~= "file" then
            for _, subnode in ipairs(node.nodes) do
              procNode(subnode)
            end
          else
            table.insert(bufferlist, node.absolute_path)
            if node.absolute_path == current_buffer then
              pos = #bufferlist
            end
          end
        end
        procNode(require("nvim-tree.api").tree.get_nodes())
        return bufferlist, pos
      end
      -- conditional setup based on whether tree is showing
      api.events.subscribe(api.events.Event.TreeOpen, function(_)
        -- expand all folders
        api.tree.expand_all()
        -- hide bufferbar
        vim.opt.showtabline = 0
        vim.schedule(function()
          vim.cmd.doautocmd("VimEnter")
        end)
        -- remap tab
        vim.keymap.set("n", "<tab>", function()
          api.tree.expand_all()
          local bufferlist, pos = get_buffers()
          if pos == #bufferlist then
            vim.cmd("buffer " .. bufferlist[1])
          else
            vim.cmd("buffer " .. bufferlist[pos + 1])
          end
        end, { silent = true, desc = "go to next buffer" })
        vim.keymap.set("n", "<s-tab>", function()
          api.tree.expand_all()
          local bufferlist, pos = get_buffers()
          if pos == 1 then
            vim.cmd("buffer " .. bufferlist[#bufferlist])
          else
            vim.cmd("buffer " .. bufferlist[pos - 1])
          end
        end, { silent = true, desc = "go to previous buffer" })
      end)
      api.events.subscribe(api.events.Event.TreeClose, function(_)
        -- show bufferbar
        vim.opt.showtabline = 2
        vim.schedule(function()
          vim.cmd.doautocmd("VimEnter")
        end)
        -- remap tab to their regular mappings
        vim.keymap.set("n", "<tab>", function()
          vim.cmd("bn")
        end, { silent = true, desc = "go to next buffer" })
        vim.keymap.set("n", "<s-tab>", function()
          vim.cmd("bp")
        end, { silent = true, desc = "go to previous buffer" })
      end)
      -- close buffer tree if we're the last window around
      vim.api.nvim_create_autocmd({ "QuitPre" }, {
        group = vim.api.nvim_create_augroup("autoclose_tree", { clear = true }),
        callback = function()
          local wins = vim.api.nvim_list_wins()
          local realwins = #wins - 1 -- the one being closed has to be subtracted
          for _, w in ipairs(wins) do
            local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
            if bufname == "" or bufname:match("NvimTree_") ~= nil then
              realwins = realwins - 1
            end
          end
          if realwins < 1 then
            vim.cmd("NvimTreeClose")
          end
        end,
      })
      -- finally, setup
      require("nvim-tree").setup(opts)
    end,
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
    opts = {
      enable = false,
    },
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
    "Ajaymamtora/telescope-undo.nvim",
    enabled = false,
    -- dev = true,
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

  {
    "zk-org/zk-nvim",
    event = "VeryLazy",
    main = "zk",
    opts = {},
  },
})
