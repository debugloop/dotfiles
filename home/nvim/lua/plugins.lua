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
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        go = { "gofumpt", "goimports-reviser" },
        lua = { "stylua" },
        nix = { "nixpkgs_fmt" },
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
    clone = true,
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
    "echasnovski/mini.nvim",
    main = "mini.ai",
    name = "mini.ai",
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
    "echasnovski/mini.nvim",
    main = "mini.bufremove",
    name = "mini.bufremove",
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
    "echasnovski/mini.nvim",
    main = "mini.clue",
    name = "mini.clue",
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
    "echasnovski/mini.nvim",
    main = "mini.diff",
    name = "mini.diff",
    event = "UIEnter",
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
    config = function(_, opts)
      vim.api.nvim_set_hl(0, "MiniDiffSignAdd", { link = "diffAdded" })
      vim.api.nvim_set_hl(0, "MiniDiffSignChange", { link = "diffChanged" })
      vim.api.nvim_set_hl(0, "MiniDiffSignDelete", { link = "diffDeleted" })
      require("mini.diff").setup(opts)
    end,
  },

  {
    "echasnovski/mini.nvim",
    main = "mini.files",
    name = "mini.files",
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
    "echasnovski/mini.nvim",
    main = "mini.git",
    name = "mini.git",
    event = "VeryLazy",
    keys = {
      {
        "<leader>gi",
        mode = { "n", "v" },
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
    "echasnovski/mini.nvim",
    main = "mini.hipatterns",
    name = "mini.hipatterns",
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
    "echasnovski/mini.nvim",
    clone = true,
    main = "mini.icons",
    name = "mini.icons",
    event = "VeryLazy",
    opts = {},
  },

  {
    "echasnovski/mini.nvim",
    main = "mini.indentscope",
    name = "mini.indentscope",
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
    "echasnovski/mini.nvim",
    main = "mini.jump",
    name = "mini.jump",
    event = "VeryLazy",
    opts = {},
    config = function(_, opts)
      require("mini.jump").setup(opts)
      vim.api.nvim_set_hl(0, "MiniJump", { link = "@comment.note" })
    end,
  },

  {
    "echasnovski/mini.nvim",
    main = "mini.move",
    name = "mini.move",
    event = "VeryLazy",
    keys = {
      { "<leader>M", "<nop>", { desc = "+move" } },
    },
    opts = {
      mappings = {
        left = "<leader>Mh",
        right = "<leader>Ml",
        down = "<leader>Mj",
        up = "<leader>Mk",
        line_left = "<leader>Mh",
        line_right = "<leader>Ml",
        line_down = "<leader>Mj",
        line_up = "<leader>Mk",
      },
    },
  },

  {
    "echasnovski/mini.nvim",
    main = "mini.operators",
    name = "mini.operators",
    event = "VeryLazy",
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
    "echasnovski/mini.nvim",
    main = "mini.pairs",
    name = "mini.pairs",
    event = "InsertEnter",
    opts = {
      mappings = {
        ["("] = { action = "open", pair = "()", neigh_pattern = "[^\\][%s%)%]}]" },
        ["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\][%s%)%]}]" },
        ["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\][%s%)%]}]" },
        -- we use the default close actions
        ['"'] = { action = "closeopen", pair = '""', neigh_pattern = "[^\\][%s%)%]}]", register = { cr = false } },
        ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%a\\][%s%)%]}]", register = { cr = false } },
        ["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^\\][%s%)%]}]", register = { cr = false } },
      },
    },
  },

  {
    "echasnovski/mini.nvim",
    main = "mini.pick",
    name = "mini.pick",
    dependencies = {
      {
        "echasnovski/mini.nvim",
        main = "mini.extra",
        name = "mini.extra",
      },
    },
    event = "VeryLazy",
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
    "echasnovski/mini.nvim",
    main = "mini.splitjoin",
    name = "mini.splitjoin",
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
    "echasnovski/mini.nvim",
    clone = true,
    main = "mini.statusline",
    name = "mini.statusline",
    dependencies = {
      {
        "echasnovski/mini.nvim",
        main = "mini.icons",
        name = "mini.icons",
      },
    },
    event = "VeryLazy",
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
          if DEBUG_MODE then
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
            }):gsub(" %%", "%%"),
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
    "echasnovski/mini.nvim",
    enabled = false, -- surrounding stuff is so rare, let's use `s` better
    main = "mini.surround",
    name = "mini.surround",
    keys = { "s" },
    opts = {
      search_method = "cover_or_next",
    },
  },

  {
    "echasnovski/mini.nvim",
    clone = true,
    main = "mini.tabline",
    name = "mini.tabline",
    dependencies = {
      {
        "echasnovski/mini.nvim",
        main = "mini.icons",
        name = "mini.icons",
      },
    },
    event = "VeryLazy",
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
    "echasnovski/mini.nvim",
    main = "mini.visits",
    name = "mini.visits",
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
        long_message_to_split = true,
      },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      views = {
        mini = {
          timeout = 3000,
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
    },
    opts = {
      func_map = {
        open = "o",
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
        pscrollup = "<C-u>",
        pscrolldown = "<C-d>",
        pscrollorig = "zz",
        prevfile = "K",
        nextfile = "J",
        prevhist = "<",
        nexthist = ">",
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
    config = function(_, opts)
      require("bqf").setup(opts)
      vim.api.nvim_set_hl(0, "BqfPreviewTitle", { link = "BqfPreviewBorder" })
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    module = false,
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp" },
    },
    opts = function()
      require("snippets").register_cmp_source()
      require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
      local kind_icons = {
        Text = "",
        Method = "󰆧",
        Function = "󰊕",
        Constructor = "",
        Field = "󰇽",
        Variable = "󰂡",
        Class = "󰠱",
        Interface = "",
        Module = "",
        Property = "󰜢",
        Unit = "",
        Value = "󰎠",
        Enum = "",
        Keyword = "󰌋",
        Snippet = "",
        Color = "󰏘",
        File = "󰈙",
        Reference = "",
        Folder = "󰉋",
        EnumMember = "",
        Constant = "󰏿",
        Struct = "",
        Event = "",
        Operator = "󰆕",
        TypeParameter = "󰅲",
      }
      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end
      local cmp = require("cmp")
      return {
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "snippets" },
          {
            name = "lazydev",
            group_index = 0, -- set group index to 0 to skip loading LuaLS completions
          },
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
        formatting = {
          format = function(_, vim_item)
            vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind:lower())
            return vim_item
          end,
        },
        experimental = {
          ghost_text = {
            hl_group = "@comment",
          },
        },
        preselect = cmp.PreselectMode.None,
        mapping = {
          ["<tab>"] = cmp.mapping(function(fallback)
            if vim.snippet.active({ direction = 1 }) then
              vim.snippet.jump(1)
            elseif cmp.visible() then
              cmp.select_next_item()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<s-tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<cr>"] = cmp.mapping({
            i = function(fallback)
              if cmp.visible() and cmp.get_active_entry() then
                cmp.confirm({
                  behavior = cmp.ConfirmBehavior.Replace,
                  select = false,
                })
              else
                fallback()
              end
            end,
            s = cmp.mapping.confirm({ select = true }),
          }),
        },
      }
    end,
  },

  {
    "mfussenegger/nvim-dap",
    module = false,
    keys = {
      {
        "<leader>d",
        function()
          local dap = require("dap")
          if dap.session() ~= nil then
            EnterDebugMode()
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
      -- utility functions
      local function quit_debugging()
        dap.listeners.after.event_stopped["refresh_expr"] = nil
        vim.cmd("pclose")
        dap.terminate()
        dap.repl.close()
      end
      -- debug mode entry and exit
      function EnterDebugMode()
        DEBUG_MODE = true
        -- evaluate expression continuously
        vim.keymap.set("n", "e", function()
          local exp = vim.fn.input("Expression: ")
          if exp == "" then
            vim.fn.expand("<cexpr>")
          end
          local prefix = exp:sub(-1) == ")" and "call " or ""
          require("dap.ui.widgets").preview(prefix .. exp)
          dap.listeners.after.event_stopped["refresh_expr"] = function()
            require("dap.ui.widgets").preview(prefix .. exp)
          end
        end, { desc = "debug: auto evaluate expression" })
        -- clear evaluation watch
        vim.keymap.set("n", "E", function()
          dap.listeners.after.event_stopped["refresh_expr"] = nil
          vim.cmd("pclose")
        end, { desc = "debug: clear auto evaluate" })
        -- step over/next
        vim.keymap.set("n", "s", function()
          dap.step_over()
        end, { desc = "debug: step forward", remap = true })
        -- continue
        vim.keymap.set("n", "c", function()
          dap.continue()
        end, { desc = "debug: continue" })
        -- step into
        vim.keymap.set("n", "i", function()
          dap.step_into()
        end, { desc = "debug: step into" })
        -- step out of
        vim.keymap.set("n", "o", function()
          dap.step_out()
        end, { desc = "debug: step out" })
        -- hover with value
        vim.keymap.set("n", "J", function()
          require("dap").session():evaluate(vim.fn.expand("<cexpr>"), function(err, resp)
            if err then
              vim.print("Could not evaluate expression at cursor.")
            else
              vim.lsp.util.open_floating_preview({ resp.result }, "go", { focus_id = "dap-float" })
            end
          end)
        end, { desc = "debug: hover value" })
        -- up one frame
        vim.keymap.set("n", "u", function()
          dap.up()
        end, { desc = "debug: frame up" })
        -- down one frame
        vim.keymap.set("n", "d", function()
          dap.down()
        end, { desc = "debug: frame down" })
        -- toggle breakpoint
        vim.keymap.set("n", "b", function()
          dap.toggle_breakpoint()
        end, { desc = "debug: toggle breakpoint" })
        -- set conditional breakpoint
        vim.keymap.set("n", "B", function()
          local cond = vim.fn.input("Breakpoint condition or count: ")
          if tonumber(cond) ~= nil then
            vim.print("Breakpoint at visit #" .. cond)
            dap.set_breakpoint(nil, cond, nil)
          else
            vim.print("Breakpoint `if " .. cond .. "`")
            dap.set_breakpoint(cond, nil, nil)
          end
        end, { desc = "debug: set conditional breakpoint" })
        -- restart
        vim.keymap.set("n", "r", function()
          dap.restart()
        end, { desc = "debug: restart" })
        -- exit debug mode
        vim.keymap.set("n", "<esc>", ExitDebugMode, { desc = "debug: exit debug mode" })
        -- quit
        vim.keymap.set("n", "q", quit_debugging, { desc = "debug: quit" })
        -- quit and clear breakpoints
        vim.keymap.set("n", "Q", function()
          quit_debugging()
          dap.clear_breakpoints()
        end, { desc = "debug: quit" })
        -- exit debug mode on insert so we have <esc> available to go back to normal
        vim.api.nvim_create_autocmd("ModeChanged", {
          group = vim.api.nvim_create_augroup("on_debug_mode_exit", { clear = true }),
          pattern = "*:i",
          callback = function()
            ExitDebugMode()
          end,
        })
        vim.cmd("redrawstatus")
      end
      function ExitDebugMode()
        vim.api.nvim_del_augroup_by_name("on_debug_mode_exit")
        DEBUG_MODE = false
        vim.keymap.del("n", "b") -- toggle breakpoint
        vim.keymap.del("n", "B") -- set conditional breakpoint
        vim.keymap.del("n", "c") -- continue
        vim.keymap.del("n", "d") -- down one frame
        vim.keymap.del("n", "e") -- evaluate expression continuously
        vim.keymap.del("n", "E") -- clear evaluation watch
        vim.keymap.del("n", "<esc>") -- exit debug mode
        vim.keymap.del("n", "i") -- step into
        vim.keymap.del("n", "J") -- hover with value
        vim.keymap.del("n", "o") -- step out of
        vim.keymap.del("n", "q") -- quit
        vim.keymap.del("n", "Q") -- quit and clear breakpoints
        vim.keymap.del("n", "r") -- restart
        vim.keymap.del("n", "s") -- step over/next
        vim.keymap.del("n", "u") -- up one frame
        vim.cmd("redrawstatus")
      end
      dap.listeners.after.event_initialized["custom_maps"] = EnterDebugMode
      dap.listeners.before.event_terminated["custom_maps"] = ExitDebugMode
      dap.listeners.before.event_exited["custom_maps"] = ExitDebugMode
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
        :option({
          key = "c",
          option = "conceallevel",
          values = { [true] = 2, [false] = 0 },
        })
        -- :getter_setter({
        --   key = "d",
        --   name = "diagnostics",
        --   get = vim.lsp.diagnostic.is_enabled,
        --   set = vim.lsp.diagnostic.enable,
        -- })
        :field({
          key = "D",
          name = "diff gutter",
          table = vim.g,
          field = "minidiff_disable",
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
          key = "i",
          name = "indentscope",
          table = vim.g,
          field = "miniindentscope_disable",
        })
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
      local multiplexer = {
        require("impairative")
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
          :command_pair({
            key = "q",
            backward = "cprevious",
            forward = "cnext",
          }),
        require("impairative").operations({
          backward = "S",
          forward = "s",
        }),
      }
      function multiplexer.unified_function(self, arg)
        for _, elem in ipairs(self) do
          elem:unified_function(arg)
        end
      end
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
        multiplexer:unified_function({
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

  {
    "neovim/nvim-lspconfig",
    name = "lspconfig.gopls",
    ft = { "go", "gomod" },
    opts = {
      on_attach = function(_, bufnr)
        -- get gc details
        vim.keymap.set("n", "<leader>G", function()
          vim.lsp.buf_request_sync(0, "workspace/executeCommand", {
            command = "gopls.gc_details",
            arguments = { "file://" .. vim.api.nvim_buf_get_name(0) },
          }, 2000)
        end, { desc = "lsp: show GC details" })
        -- run current test
        vim.keymap.set("n", "<leader>t", function()
          local ok, inTestfile, testName = pcall(SurroundingTestName)
          if not ok or not inTestfile then
            return
          end
          vim.lsp.buf_request_sync(0, "workspace/executeCommand", {
            command = "gopls.run_tests",
            arguments = {
              {
                URI = vim.uri_from_bufnr(0),
                Tests = { testName },
              },
            },
          }, 10000)
          -- vim.lsp.buf.execute_command({
          --   command = "gopls.run_tests",
          -- })
        end, { desc = "lsp: show GC details" })
        -- organize imports on save
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = vim.api.nvim_create_augroup("lsp_organize_imports_on_save", { clear = false }), -- dont clear, there is one autocmd per buffer in this group
          buffer = bufnr,
          callback = function()
            local params = vim.lsp.util.make_range_params(nil, vim.lsp.util._get_offset_encoding(bufnr))
            params.context = { only = { "source.organizeImports" } }
            local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
            for _, res in pairs(result or {}) do
              for _, r in pairs(res.result or {}) do
                if r.edit then
                  vim.lsp.util.apply_workspace_edit(r.edit, vim.lsp.util._get_offset_encoding(bufnr))
                else
                  vim.lsp.buf.execute_command(r.command)
                end
              end
            end
          end,
        })
      end,
      capabilities = vim.lsp.protocol.make_client_capabilities(),
      flags = {
        allow_incremental_sync = false,
      },
      settings = {
        gopls = {
          usePlaceholders = true,
          experimentalPostfixCompletions = true,
          staticcheck = true,
          codelenses = {
            gc_details = true,
            test = true,
          },
          analyses = {
            fieldalignment = false, -- useful, but better optimize for readability
            shadow = false, -- useful, but to spammy with `err`
            unusedvariable = true,
            useany = true,
          },
          hints = {
            assignVariableTypes = true,
            compositeLiteralFields = true,
            compositeLiteralTypes = true,
            constantValues = true,
            functionTypeParameters = true,
            parameterNames = true,
            rangeVariableTypes = true,
          },
          buildFlags = { "-tags=unit,integration,e2e" },
        },
      },
    },
    config = function(_, opts)
      require("lspconfig").gopls.setup(opts)
    end,
  },

  {
    "neovim/nvim-lspconfig",
    name = "lspconfig.lua_ls",
    ft = { "lua" },
    dependencies = {
      { "folke/lazydev.nvim", opts = {} },
    },
    opts = {
      single_file_support = true,
      settings = {
        Lua = {
          telemetry = { enable = false },
        },
      },
    },
    config = function(_, opts)
      require("lspconfig").lua_ls.setup(opts)
    end,
  },

  {
    "neovim/nvim-lspconfig",
    name = "lspconfig.nil_ls",
    ft = { "nix" },
    opts = {},
    config = function(_, opts)
      require("lspconfig").nil_ls.setup(opts)
    end,
  },

  {
    "neovim/nvim-lspconfig",
    name = "lspconfig.nixd",
    ft = { "nix" },
    opts = {},
    config = function(_, opts)
      require("lspconfig").nixd.setup(opts)
    end,
  },

  -- {
  --   "neovim/nvim-lspconfig",
  --   name = "lspconfig.yamlls",
  --   ft = { "yaml" },
  --   opts = {
  --     settings = {
  --       yaml = {
  --         schemaStore = {
  --           enable = true,
  --           url = "https://www.schemastore.org/api/json/catalog.json",
  --         },
  --       },
  --     },
  --   },
  --   config = function(_, opts)
  --     require("lspconfig").yamlls.setup(opts)
  --   end,
  -- },

  {
    "yorickpeterse/nvim-pqf",
    event = "VeryLazy",
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
        HIDE_BUFFERS = true
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
        HIDE_BUFFERS = false
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
    keys = { "<leader>ot", "]ot", "[ot" },
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
            ["gz"] = "@peek", -- replaces both below
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
