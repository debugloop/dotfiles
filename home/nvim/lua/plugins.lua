local function inject(spec)
  if type(spec) ~= "table" then
    vim.notify("Encountered bad plugin spec. Must use a table, not string. Check config.", vim.log.levels.ERROR)
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
        ["_"] = { "trim_whitespace" },
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
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewPR", "DiffviewPRLog" },
    dependencies = {
      { "nvim-lua/plenary.nvim" },
    },
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
    "folke/flash.nvim",
    event = "VeryLazy",
    keys = {
      {
        "f",
        mode = { "n", "x", "o" },
        function()
          -- TODO: make eyeliner like work:
          -- https://github.com/willothy/nvim-config/blob/b3c2f3701373070a511ee8b0fb1d386257d93f7c/lua/plugins/navigation/flash.lua#L83
          local Char = require("flash.plugins.char")
          local Config = require("flash.config")
          local Repeat = require("flash.repeat")
          Repeat.setup()
          Char.jumping = true
          local autohide = Config.get("char").autohide
          if Repeat.is_repeat then
            Char.jump_labels = false
            Char.state:jump({ count = vim.v.count1 })
            Char.state:show()
          else
            Char.jump("f")
          end
          vim.schedule(function()
            Char.jumping = false
            if Char.state and autohide then
              Char.state:hide()
            end
          end)
        end,
        {
          silent = true,
        },
      },
      "F",
      "t",
      "T",
      ";",
      ",",
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash jump",
      },
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "toggle Flash search",
      },
    },
    opts = {
      search = {
        multi_window = false,
      },
      jump = {
        autojump = true,
      },
      modes = {
        search = {
          enabled = false,
          highlight = { backdrop = true },
        },
        char = {
          enabled = true,
          keys = { "F", "t", "T", ",", ";" },
          char_actions = function(motion)
            return {
              [";"] = "right",
              [","] = "left",
              [motion:lower()] = "right",
              [motion:upper()] = "left",
            }
          end,
        },
      },
    },
  },

  {
    "ruifm/gitlinker.nvim",
    keys = function()
      local keys = {}
      for _, mode in pairs({ "n", "v" }) do
        table.insert(keys, {
          "gy",
          function()
            require("gitlinker").get_buf_range_url(mode)
          end,
          desc = "copy github url",
          mode = mode,
        })
      end
      return keys
    end,
    opts = {},
  },

  {
    "rebelot/heirline.nvim",
    event = "UIEnter",
    dependencies = {
      { "rebelot/kanagawa.nvim" },
      { "echasnovski/mini.diff" },
    },
    config = function()
      -- override some settings
      vim.opt.showtabline = 0 -- no tabline ever
      vim.opt.laststatus = 3 -- global statusline
      vim.opt.showcmdloc = "statusline" -- enable partial command printing segment
      -- import required things
      local conditions = require("heirline.conditions")
      local utils = require("heirline.utils")
      local statusline = require("statusline")
      local components = statusline.components
      local static = statusline.static
      -- setup color based on the current colorscheme
      local function setup_colors()
        return statusline.colors
      end
      require("heirline").load_colors(setup_colors)
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("Heirline", { clear = true }),
        callback = function()
          utils.on_colorscheme(setup_colors)
        end,
      })
      -- declare
      require("heirline").setup({
        statusline = {
          static = static,
          {
            init = function(self)
              self.filename = vim.api.nvim_buf_get_name(0)
              self:find_mode()
            end,
            { -- left section a, inverted bright color
              hl = static.color_a,
              components.mode,
            },
            { -- left section b, bright color
              hl = static.color_b,
              components.git,
              components.lsp,
            },
            { -- middle section c, plain color
              hl = static.color_c,
              { -- left aligned
                components.space,
                components.filename,
              },
              components.truncate,
              components.fill,
              { -- right aligned
                flexible = 10,
                {
                  components.macro,
                  components.filetype,
                  components.encoding,
                  components.fileformat,
                },
              },
            },
            { -- right section b, bright color
              hl = static.color_b,
              components.ruler,
            },
            { -- right section a, inverted bright color
              hl = static.color_a,
              components.linecol,
            },
          },
        },
        winbar = {
          {
            static = static,
            init = function(self)
              self.focused_bufnr = vim.api.nvim_buf_get_number(0)
              self:find_mode()
            end,
            utils.make_buflist({
              init = function(self)
                self.filename = vim.api.nvim_buf_get_name(self.bufnr)
                self.is_displayed = self.bufnr == self.focused_bufnr
              end,
              hl = function(self)
                if conditions.is_active() then -- if this window has focus...
                  if self.is_displayed then -- ...and this is the displayed buffer
                    return self:color_a()
                  else -- ...and this is another buffer
                    return "StatusLine"
                  end
                else -- if this window is visible but unfocused...
                  if self.is_displayed then -- ...and this is the displayed buffer
                    return "Folded"
                  else -- ...and this is another buffer
                    return "StatusLineNC"
                  end
                end
              end,
              {
                components.space,
                components.bufmark,
                components.bufname,
                components.space,
              },
            }),
            components.fill,
            components.dap,
          },
        },
        opts = {
          disable_winbar_cb = function(args)
            return HIDE_BUFFERS
              or conditions.buffer_matches({
                buftype = { "nofile", "prompt", "help", "quickfix", "terminal" },
                filetype = { "^git.*", "noice", "NvimTree" },
              }, args.buf)
          end,
        },
      })
    end,
  },

  {
    "rebelot/kanagawa.nvim",
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
          -- invisible window separator
          WinSeparator = { fg = theme.ui.bg_dim, bg = theme.ui.bg_dim },
          -- nvim-tree
          NvimTreeNormal = { bg = theme.ui.bg_dim },
          NvimTreeGitDirty = { fg = theme.term[5], bg = "none" },
          NvimTreeGitStaged = { fg = theme.term[4], bg = "none" },
          -- incline
          InclineNormal = { fg = theme.ui.bg, bg = theme.syn.fun },
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
    keys = function(_, _)
      local maps = {}
      local map_start = function(op, ai)
        table.insert(maps, {
          "]" .. op,
          function()
            require("mini.ai").move_cursor("left", ai, op, { search_method = "next" })
          end,
          desc = "Goto next start of " .. ai .. op .. " textobject",
        })
        table.insert(maps, {
          "[" .. op,
          function()
            require("mini.ai").move_cursor("left", ai, op, { search_method = "cover_or_prev" })
          end,
          desc = "Goto previous start of " .. ai .. op .. " textobject",
        })
      end
      local map_end = function(op, ai)
        table.insert(maps, {
          "]" .. op:upper(),
          function()
            require("mini.ai").move_cursor("right", ai, op, { search_method = "cover_or_next" })
          end,
          desc = "Goto next end of " .. ai .. op .. " textobject",
        })
        table.insert(maps, {
          "[" .. op:upper(),
          function()
            require("mini.ai").move_cursor("right", ai, op, { search_method = "prev" })
          end,
          desc = "Goto previous end of " .. ai .. op .. " textobject",
        })
      end
      -- do actual mapping
      for _, op in pairs({ "f", "c", "i", "l", "t" }) do
        map_start(op, "a")
        map_end(op, "a")
      end
      for _, op in pairs({ "a", "s" }) do
        map_start(op, "i")
        map_end(op, "i")
      end
      for _, op in pairs({ "b", "B", "<", ">", '"', "'", "`" }) do
        map_start(op, "i")
      end
      return maps
    end,
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
    main = "mini.bracketed",
    name = "mini.bracketed",
    keys = { "]", "[" },
    opts = {
      buffer = { suffix = "", options = {} },
      comment = { suffix = "", options = {} },
      conflict = { suffix = "x", options = {} },
      diagnostic = { suffix = "d", options = {} },
      file = { suffix = "", options = {} },
      indent = { suffix = "", options = {} },
      jump = { suffix = "j", options = {} },
      location = { suffix = "", options = {} },
      oldfile = { suffix = "", options = {} },
      quickfix = { suffix = "q", options = {} },
      treesitter = { suffix = "", options = {} },
      undo = { suffix = "", options = {} },
      window = { suffix = "", options = {} },
      yank = { suffix = "y", options = {} },
    },
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
          -- maps that don't quit option mode (all of them)
          { mode = "n", keys = "<leader>ob", postkeys = "<leader>o" }, -- background
          { mode = "n", keys = "<leader>oc", postkeys = "<leader>o" }, -- conceal
          { mode = "n", keys = "<leader>oI", postkeys = "<leader>o" }, -- indentscope
          { mode = "n", keys = "<leader>ol", postkeys = "<leader>o" }, -- list
          { mode = "n", keys = "<leader>oL", postkeys = "<leader>o" }, -- LSP
          { mode = "n", keys = "<leader>on", postkeys = "<leader>o" }, -- number
          { mode = "n", keys = "<leader>or", postkeys = "<leader>o" }, -- relativenumber
          { mode = "n", keys = "<leader>os", postkeys = "<leader>o" }, -- spell
          { mode = "n", keys = "<leader>ot", postkeys = "<leader>o" }, -- treesitter context
          { mode = "n", keys = "<leader>oi", postkeys = "<leader>o" }, -- treesitter illumination
          { mode = "n", keys = "<leader>oS", postkeys = "<leader>o" }, -- treesitter scope display
          { mode = "n", keys = "<leader>ov", postkeys = "<leader>o" }, -- virtualedit
          { mode = "n", keys = "<leader>ow", postkeys = "<leader>o" }, -- wrap
          { mode = "n", keys = "<leader>ox", postkeys = "<leader>o" }, -- cursorcolumn
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
    main = "mini.comment",
    name = "mini.comment",
    event = "VeryLazy", -- event based, so the text object is also available the start
    keys = {
      {
        "gcc",
        "gcl",
        desc = "comment current line",
      },
    },
    opts = {},
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
          require("mini.diff").toggle_overlay()
        end,
        desc = "Show details",
      },
      {
        "<leader>gb",
        function()
          local linenum = vim.api.nvim_win_get_cursor(0)[1]
          local filename = vim.fn.expand("%")
          local blame = vim.fn.system(
            "git log --date=relative --format='%ad by %an - %s' -s -L" .. linenum .. "," .. linenum .. ":" .. filename
          )
          vim.notify(blame)
        end,
        desc = "Show git blame",
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
      },
      mappings = {
        apply = "ga",
        reset = "<leader>gR",
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
        prefix = "gR",
      },
      -- defaults:
      evaluate = {
        prefix = "g=",
      },
      exchange = {
        prefix = "gx",
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
        "<Bslash>",
        function()
          require("mini.pick").builtin.buffers()
        end,
        desc = "find buffers",
      },
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
        "<leader>t",
        function()
          require("mini.extra").pickers.treesitter()
        end,
        desc = "find in treesitter",
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
    main = "mini.surround",
    name = "mini.surround",
    keys = { "s" },
    opts = {
      search_method = "cover_or_next",
    },
    config = function(opts)
      vim.keymap.set({ "n", "v" }, "s", "<nop>")
      require("mini.surround").setup(opts)
    end,
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
      { "rcarriga/nvim-notify" },
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
      messages = {
        enabled = true,
        view = "mini",
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
  },

  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp" },
      { "dcampos/nvim-snippy" },
      { "dcampos/cmp-snippy" },
    },
    opts = function()
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
      local snippy = require("snippy")
      return {
        enabled = function()
          local context = require("cmp.config.context")
          return vim.api.nvim_get_mode().mode ~= "c"
            and not (context.in_treesitter_capture("comment") or context.in_syntax_group("Comment"))
        end,
        sources = cmp.config.sources({
          { name = "snippy" },
          { name = "nvim_lsp" },
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
        snippet = {
          expand = function(args)
            require("snippy").expand_snippet(args.body)
          end,
        },
        preselect = cmp.PreselectMode.None,
        mapping = {
          ["<tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif snippy.can_expand_or_advance() then
              snippy.expand_or_advance()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<s-tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif snippy.can_jump(-1) then
              snippy.previous()
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
          if vim.fn.expand("%:t"):sub(-#"_test.go", -1) == "_test.go" then
            -- see if we can find a specific test to run
            local cursor = vim.api.nvim_win_get_cursor(0)
            local lsp_response, lsp_err = vim.lsp.buf_request_sync(
              0,
              "textDocument/documentSymbol",
              { textDocument = vim.lsp.util.make_text_document_params() },
              1000
            )
            if lsp_err == nil then
              for _, symbol in pairs(lsp_response[1].result) do
                if
                  symbol["detail"] ~= nil
                  and symbol.detail:sub(1, 4) == "func"
                  and symbol.name:sub(1, 4) == "Test"
                  and cursor[1] > symbol.range.start.line
                  and cursor[1] < symbol.range["end"].line
                then
                  dap.run({
                    type = "go",
                    name = symbol.name,
                    request = "launch",
                    mode = "test",
                    program = "./" .. vim.fn.fnamemodify(vim.fn.expand("%:.:h"), ":r"),
                    args = { "-test.run", "^" .. symbol.name .. "$" },
                    buildFlags = "-tags=unit,integration,e2e",
                  })
                  return
                end
              end
            end
            -- if we can't find a specific one we could run the whole test file:
            dap.run(dap.configurations.go[1])
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
        -- display code lenses
        vim.keymap.set("n", "<leader>G", function()
          vim.lsp.buf_request_sync(0, "workspace/executeCommand", {
            command = "gopls.gc_details",
            arguments = { "file://" .. vim.api.nvim_buf_get_name(0) },
          }, 2000)
        end, { desc = "lsp: show GC details" })
        -- organize imports on save
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = vim.api.nvim_create_augroup("lsp_organize_imports_on_save", { clear = false }), -- dont clear, there is one autocmd per buffer in this group
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
      end,
      capabilities = vim.lsp.protocol.make_client_capabilities(),
      -- cmd_env = { GOFLAGS = "-tags=unit,integration,e2e" },
      flags = {
        allow_incremental_sync = false,
      },
      settings = {
        gopls = {
          staticcheck = true,
          codelenses = {
            gc_details = true,
          },
          analyses = {
            fieldalignment = false,
            nilness = true,
            shadow = false, -- useful but to spammy with `err`
            unusedparams = true,
            unusedwrite = true,
            useany = true,
            unusedvariable = true,
          },
          hints = {
            assignVariableTypes = true,
            compositeLiteralFields = true,
            constantValues = true,
            functionTypeParameters = true,
            parameterNames = true,
            rangeVariableTypes = true,
          },
          buildFlags = { "-tags=unit,integration,e2e" },
          -- directoryFilters = { "vendor" },
          -- expandWorkspaceToModule = true,
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
    opts = function(_, _)
      local runtime_path = vim.split(package.path, ";")
      table.insert(runtime_path, "lua/?.lua")
      table.insert(runtime_path, "lua/?/init.lua")
      return {
        capabilities = vim.lsp.protocol.make_client_capabilities(),
        settings = {
          Lua = {
            workspace = {
              checkThirdParty = false,
            },
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
      }
    end,
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
    event = "BufReadPost",
  },

  {
    "nvim-treesitter/nvim-treesitter-refactor",
    main = "nvim-treesitter.configs",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter" },
    },
    event = "BufReadPost",
    opts = {
      refactor = {
        highlight_definitions = {
          enable = true,
        },
        highlight_current_scope = {
          enable = false,
        },
        smart_rename = {
          enable = false,
        },
        navigation = {
          enable = true,
          keymaps = {
            goto_definition = false,
            list_definitions = false,
            list_definitions_toc = false,
            goto_next_usage = "]]",
            goto_previous_usage = "[[",
          },
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
      vim.api.nvim_set_hl(0, "TSDefinition", { link = "IncSearch" })
      vim.api.nvim_set_hl(0, "TSDefinitionUsage", { link = "CurSearch" })
      vim.keymap.set("n", "<leader>oi", function()
        vim.cmd("TSBufToggle refactor.highlight_definitions")
      end, { desc = "set treesitter illumination" })
      vim.keymap.set("n", "<leader>oS", function()
        vim.cmd("TSBufToggle refactor.highlight_current_scope")
      end, { desc = "set treesitter scope" })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    main = "nvim-treesitter.configs",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter" },
    },
    event = "BufReadPost",
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
          enable = false,
        },
        select = {
          enable = false,
          lookahead = true,
          include_surrounding_whitespace = false,
          keymaps = {
            ["ia"] = { query = "@parameter.inner", desc = "select parameter" },
            ["aa"] = { query = "@parameter.outer", desc = "select parameter with delimiters" },
            ["ic"] = { query = "@call.inner", desc = "select call arguments" },
            ["ac"] = { query = "@call.outer", desc = "select call" },
            ["if"] = { query = "@function.inner", desc = "select function body" },
            ["af"] = { query = "@function.outer", desc = "select function" },
            ["ii"] = { query = "@customconditional.inner", desc = "select conditional body" },
            ["ai"] = { query = "@conditional.outer", desc = "select conditional" },
            ["il"] = { query = "@customloop.inner", desc = "select loop body" },
            ["al"] = { query = "@loop.outer", desc = "select loop" },
            ["is"] = { query = "@customblock.inner", desc = "select scope body" },
            ["as"] = { query = "@block.outer", desc = "select scope" },
            ["it"] = { query = "@customtype.inner", desc = "select type body" },
            ["at"] = { query = "@customtype.outer", desc = "select type" },
          },
        },
        move = {
          enable = false,
          set_jumps = true,
          goto_next_start = {
            ["]a"] = "@parameter.inner",
            ["]c"] = "@call.outer",
            ["]f"] = "@function.outer",
            ["]i"] = "@conditional.outer",
            ["]l"] = "@loop.outer",
            ["]s"] = "@customblock.inner",
            ["]t"] = "@customtype.outer",
          },
          goto_next_end = {
            ["]A"] = "@parameter.inner",
            ["]C"] = "@call.outer",
            ["]F"] = "@function.outer",
            ["]L"] = "@loop.outer",
            ["]M"] = "@call.outer",
            ["]S"] = "@customblock.inner",
            ["]T"] = "@customtype.outer",
          },
          goto_previous_start = {
            ["[a"] = "@parameter.inner",
            ["[c"] = "@call.outer",
            ["[f"] = "@function.outer",
            ["[i"] = "@conditional.outer",
            ["[l"] = "@loop.outer",
            ["[s"] = "@customblock.inner",
            ["[t"] = "@customtype.outer",
          },
          goto_previous_end = {
            ["[A"] = "@parameter.inner",
            ["[C"] = "@call.outer",
            ["[F"] = "@function.outer",
            ["[L"] = "@loop.outer",
            ["[M"] = "@call.outer",
            ["[S"] = "@customblock.inner",
            ["[T"] = "@customtype.outer",
          },
        },
      },
    },
  },

  {
    "debugloop/telescope-undo.nvim",
    dev = true,
    dependencies = {
      {
        "nvim-telescope/telescope.nvim",
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
