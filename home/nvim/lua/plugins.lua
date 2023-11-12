local function from_nixpkgs(spec)
  local name = spec[1]
  local plugin_name = name:match("[^/]+$")
  if spec["dir"] == nil then
    spec["dir"] = vim.fn.stdpath("data") .. "/nixpkgs/" .. plugin_name:gsub("%.", "-")
  end
  return spec
end

return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = { "ConformInfo" },
    commit = "4ecb4b07e2eca6f53dcc348d8c7120961abcbce9", -- TODO: revert to nixpkgs once https://github.com/stevearc/conform.nvim/pull/176 is in
    opts = {
      formatters_by_ft = {
        go = { "gofumpt", "goimports-reviser" },
        lua = { "stylua" },
        nix = { "nixpkgs_fmt" },
        -- ["_"] = { "trim_whitespace" },
      },
      log_level = vim.log.levels.DEBUG,
      format_on_save = {
        lsp_fallback = true,
        timeout_ms = 5000,
      },
    },
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },

  from_nixpkgs({
    "sindrets/diffview.nvim",
    cmd = { "PRDiff", "PRLog" },
    keys = {
      {
        "<leader>D",
        ":DiffviewOpen ",
        desc = "diffview: open",
      },
      {
        "<leader>L",
        ":DiffviewFileHistory ",
        desc = "diffview: history",
      },
    },
    dependencies = {
      from_nixpkgs({ "nvim-lua/plenary.nvim" }),
    },
    opts = {
      default_args = {
        DiffviewOpen = { "--imply-local" },
      },
      hooks = {
        diff_buf_read = function(bufnr)
          vim.opt_local.wrap = false
          vim.opt_local.relativenumber = false
          vim.opt_local.cursorline = false
        end,
      },
    },
    config = function(_, opts)
      require("diffview").setup(opts)
      vim.api.nvim_create_user_command("PRDiff", function()
        vim.cmd("DiffviewOpen origin/main...HEAD")
      end, { desc = "open diffview for current PR" })
      vim.api.nvim_create_user_command("PRLog", function()
        vim.cmd("DiffviewFileHistory --range=origin/main...HEAD --right-only --no-merges")
      end, { desc = "open diffview for current PR" })
    end,
  }),

  from_nixpkgs({
    "folke/flash.nvim",
    keys = {
      "f",
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
      modes = {
        search = {
          enabled = false,
          highlight = { backdrop = true },
        },
        char = {
          enabled = true,
          keys = { "f", "F", "t", "T", ",", ";" },
          config = function(opts)
            opts.autohide = vim.fn.mode(true):find("no")
          end,
          multi_line = false,
          highlight = { backdrop = false },
        },
      },
      label = {
        uppercase = false,
        current = false,
      },
    },
  }),

  from_nixpkgs({
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
  }),

  from_nixpkgs({
    "lewis6991/gitsigns.nvim",
    event = "UIEnter",
    keys = {
      {
        "]g",
        function()
          for _ = 1, vim.v.count1 do
            require("gitsigns").next_hunk()
          end
        end,
        desc = "goto next git change hunk",
        mode = { "n", "x", "o" },
      },
      {
        "[g",
        function()
          for _ = 1, vim.v.count1 do
            require("gitsigns").prev_hunk()
          end
        end,
        desc = "goto previous git change hunk",
        mode = { "n", "x", "o" },
      },
      { "<leader>g", "<nop>", { desc = "+git" } },
      {
        "<leader>gR",
        function()
          require("gitsigns").reset_hunk()
        end,
        desc = "restore hunk",
        mode = "n",
      },
      {
        "<leader>gs",
        function()
          require("gitsigns").stage_hunk()
        end,
        desc = "stage hunk",
        mode = "n",
      },
      {
        "<leader>gs",
        function()
          require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end,
        desc = "stage hunk",
        mode = "v",
      },
      {
        "<leader>gS",
        function()
          require("gitsigns").stage_buffer()
        end,
        desc = "stage buffer",
      },
      {
        "<leader>gu",
        function()
          require("gitsigns").undo_stage_hunk()
        end,
        desc = "unstage last staged hunk",
      },
      {
        "<leader>gU",
        function()
          require("gitsigns").reset_buffer_index()
        end,
        desc = "unstage buffer",
      },
      {
        "<leader>gd",
        function()
          require("gitsigns").toggle_deleted()
        end,
        desc = "toggle display of deleted lines",
      },
      {
        "<leader>gG",
        function()
          require("gitsigns").toggle_linehl(true)
          require("gitsigns").toggle_deleted(true)
          require("gitsigns").toggle_current_line_blame(true)
          require("gitsigns").refresh()
          require("gitsigns").toggle_word_diff(true)
          require("gitsigns").refresh()
        end,
        desc = "turn on all git stuff",
      },
      {
        "<leader>gg",
        function()
          require("gitsigns").toggle_linehl(false)
          require("gitsigns").toggle_deleted(false)
          require("gitsigns").toggle_word_diff(false)
          require("gitsigns").toggle_current_line_blame(false)
          require("gitsigns").refresh()
        end,
        desc = "turn off all git stuff, default",
      },
      {
        "<leader>gl",
        function()
          require("gitsigns").toggle_linehl()
        end,
        desc = "toggle line highlight",
      },
      {
        "<leader>gw",
        function()
          require("gitsigns").toggle_word_diff()
        end,
        desc = "toggle word diff",
      },
      {
        "<leader>gb",
        function()
          require("gitsigns").toggle_current_line_blame()
        end,
        desc = "toggle blame line",
      },
      {
        "<leader>gc",
        function()
          require("gitsigns").change_base(vim.fn.input("Ref: "), true)
        end,
        desc = "change base",
      },
      {
        "<leader>go",
        function()
          require("gitsigns").show(vim.fn.input("Ref: "))
        end,
        desc = "open file at ref",
      },
      {
        "<leader>gD",
        function()
          require("gitsigns").diffthis(vim.fn.input("Ref: "))
        end,
        desc = "diff file against ref",
      },
    },
    opts = {
      current_line_blame_opts = {
        ignore_whitespace = true,
        delay = 300,
      },
    },
  }),

  from_nixpkgs({
    "rebelot/heirline.nvim",
    event = "UIEnter",
    dependencies = { from_nixpkgs({ "rebelot/kanagawa.nvim" }) },
    config = function()
      vim.opt.showtabline = 0 -- no tabline ever
      vim.opt.laststatus = 2 -- windowed statusline
      vim.opt.showcmdloc = "statusline" -- enable partial command printing segment
      local conditions = require("heirline.conditions")
      local utils = require("heirline.utils")
      local function setup_colors()
        return {
          bg = utils.get_highlight("StatusLine").bg,
          fg = utils.get_highlight("StatusLine").fg,
          bright_bg = utils.get_highlight("Folded").bg,
          bright_fg = utils.get_highlight("Folded").fg,
          red = utils.get_highlight("DiagnosticError").fg,
          green = utils.get_highlight("String").fg,
          blue = utils.get_highlight("Function").fg,
          orange = utils.get_highlight("Constant").fg,
          purple = utils.get_highlight("Statement").fg,
          diag_warn = utils.get_highlight("DiagnosticWarn").fg,
          diag_error = utils.get_highlight("DiagnosticError").fg,
          diag_hint = utils.get_highlight("DiagnosticHint").fg,
          diag_info = utils.get_highlight("DiagnosticInfo").fg,
          git_del = utils.get_highlight("diffDeleted").fg,
          git_add = utils.get_highlight("diffAdded").fg,
          git_change = utils.get_highlight("diffChanged").fg,
        }
      end
      require("heirline").load_colors(setup_colors)
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("Heirline", { clear = true }),
        callback = function()
          utils.on_colorscheme(setup_colors)
        end,
      })
      require("heirline").setup({
        tabline = {},
        statusline = {
          static = {
            mode_colors = {
              n = "blue",
              i = "green",
              v = "purple",
              ["\22"] = "purple",
              c = "orange",
              s = "purple",
              r = "git_del",
              t = "green",
              debug_mode = "git_del",
            },
            make_sections = function(_, color)
              return {
                a = { fg = "bg", bg = color },
                b = { fg = color },
                c = "StatusLine",
              }
            end,
            get_mode_color = function(self)
              if conditions.is_active() then
                return self:make_sections(self.mode_colors[self.mode:lower()])
              else
                return { a = "StatusLineNC", b = "StatusLineNC", c = "StatusLineNC" }
              end
            end,
          },
          {
            init = function(self)
              self.mode = vim.fn.mode()
              self.filename = vim.api.nvim_buf_get_name(0)
              if DEBUG_MODE then
                self.mode = "DEBUG_MODE"
              end
            end,
            { -- left section a
              hl = function(self)
                return self:get_mode_color().a
              end,
              {
                static = {
                  mode_names = {
                    n = "NORMAL",
                    v = "VISUAL",
                    V = "V-LINE",
                    ["\22"] = "V-BLOCK",
                    i = "INSERT",
                    R = "REPLACE",
                    c = "COMMAND",
                    t = "TERMINAL",
                    s = "SNIPPET",
                  },
                },
                provider = function(self)
                  if not conditions.is_active() then
                    return " INACTIVE "
                  end
                  if DEBUG_MODE then
                    return " DEBUG "
                  end
                  local name = self.mode_names[self.mode]
                  if name == "" or name == nil then
                    name = vim.fn.mode(true)
                  end
                  return " " .. name .. " "
                end,
              },
            },
            { -- left section b
              hl = function(self)
                return self:get_mode_color().b
              end,
              { -- git
                condition = conditions.is_git_repo,
                init = function(self)
                  self.status_dict = vim.b.gitsigns_status_dict
                  self.has_changes = self.status_dict.added ~= 0
                    or self.status_dict.removed ~= 0
                    or self.status_dict.changed ~= 0
                end,
                {
                  flexible = 20,
                  {
                    provider = function(self)
                      return "  " .. self.status_dict.head
                    end,
                  },
                  {
                    provider = function(self)
                      return " " .. self.status_dict.head
                    end,
                  },
                },
                {
                  condition = conditions.is_active,
                  {
                    condition = function(self)
                      return self.has_changes
                    end,
                    provider = " ",
                  },
                  {
                    provider = function(self)
                      local count = self.status_dict.added or 0
                      return count > 0 and ("+" .. count .. " ")
                    end,
                    hl = { fg = "git_add" },
                  },
                  {
                    provider = function(self)
                      local count = self.status_dict.changed or 0
                      return count > 0 and ("~" .. count .. " ")
                    end,
                    hl = { fg = "git_change" },
                  },
                  {
                    provider = function(self)
                      local count = self.status_dict.removed or 0
                      return count > 0 and ("-" .. count .. " ")
                    end,
                    hl = { fg = "git_del" },
                  },
                },
              },
              { -- lsp
                condition = function()
                  return conditions.is_active() and conditions.has_diagnostics()
                end,
                init = function(self)
                  self.errors = #vim.diagnostic.get(0, {
                    severity = vim.diagnostic.severity.ERROR,
                  })
                  self.warnings = #vim.diagnostic.get(0, {
                    severity = vim.diagnostic.severity.WARN,
                  })
                  self.hints = #vim.diagnostic.get(0, {
                    severity = vim.diagnostic.severity.HINT,
                  })
                  self.info = #vim.diagnostic.get(0, {
                    severity = vim.diagnostic.severity.INFO,
                  })
                end,
                update = { "DiagnosticChanged", "BufEnter" },
                {
                  provider = " ",
                },
                {
                  provider = function(self)
                    return self.errors > 0 and ("E:" .. self.errors .. " ")
                  end,
                  hl = { fg = "diag_error" },
                },
                {
                  provider = function(self)
                    return self.warnings > 0 and ("W:" .. self.warnings .. " ")
                  end,
                  hl = { fg = "diag_warn" },
                },
                {
                  provider = function(self)
                    return self.info > 0 and ("I:" .. self.info .. " ")
                  end,
                  hl = { fg = "diag_info" },
                },
                {
                  provider = function(self)
                    return self.hints > 0 and ("H:" .. self.hints .. " ")
                  end,
                  hl = { fg = "diag_hint" },
                },
              },
            },
            { -- truncate marker
              provider = "%<",
            },
            { -- middle section c
              hl = function(self)
                return self:get_mode_color().c
              end,
              { -- left section c
                flexible = 50,
                {
                  provider = function(self)
                    local fqn = vim.fn.fnamemodify(self.filename, ":.")
                    if fqn:sub(1, 1) ~= "/" then
                      return " ./" .. fqn
                    else
                      return " " .. fqn
                    end
                  end,
                },
                {
                  provider = function(self)
                    return " " .. vim.fn.fnamemodify(self.filename, ":.")
                  end,
                },
                {
                  provider = function(self)
                    return " " .. vim.fn.pathshorten(vim.fn.fnamemodify(self.filename, ":."))
                  end,
                },
              },
              { -- fill middle
                provider = "%=",
              },
              { -- right section c
                flexible = 10,
                {
                  -- {
                  --   condition = function()
                  --     return vim.o.cmdheight == 0
                  --   end,
                  --   provider = "%3.5(%S%) ",
                  --   hl = { fg = "grey" },
                  -- },
                  {
                    hl = { fg = "orange" },
                    condition = function()
                      return conditions.is_active() and vim.fn.reg_recording() ~= "" and vim.o.cmdheight == 0
                    end,
                    provider = function()
                      return " @" .. vim.fn.reg_recording()
                    end,
                    update = {
                      "RecordingEnter",
                      "RecordingLeave",
                    },
                  },
                  {
                    provider = function()
                      return " " .. vim.bo.filetype .. " "
                    end,
                  },
                  {
                    provider = function()
                      local enc = (vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc
                      return enc ~= "utf-8" and enc .. " "
                    end,
                  },
                  {
                    provider = function()
                      local fmt = vim.bo.fileformat
                      return fmt ~= "unix" and fmt .. " "
                    end,
                  },
                },
                {},
              },
            },
            { -- right section b
              hl = function(self)
                return self:get_mode_color().b
              end,
              {
                provider = " %p%%/%L ",
              },
            },
            { -- right section a
              hl = function(self)
                return self:get_mode_color().a
              end,
              {
                provider = " %l:%v ",
              },
              -- {
              --   static = {
              --     sbar = { '🭶', '🭷', '🭸', '🭹', '🭺', '🭻' },
              --   },
              --   provider = function(self)
              --     local curr_line = vim.api.nvim_win_get_cursor(0)[1]
              --     local lines = vim.api.nvim_buf_line_count(0)
              --     local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
              --     return self.sbar[i]
              --   end,
              -- },
            },
          },
        },
        winbar = {
          {
            init = function(self)
              self.active = vim.api.nvim_buf_get_number(0)
            end,
            utils.make_buflist({
              init = function(self)
                self.filename = vim.api.nvim_buf_get_name(self.bufnr)
                self.is_active = self.bufnr == self.active
              end,
              hl = function(self)
                -- if this window is active (has focus)
                if conditions.is_active() then
                  -- if this is the active buffer in this window
                  if self.is_active then
                    return { bg = "blue", fg = "bg" }
                  else
                    return "StatusLine"
                  end
                else
                  -- if this is the active buffer in this window
                  if self.is_active then
                    return "Folded"
                  else
                    return "StatusLineNC"
                  end
                end
              end,
              {
                { -- marker
                  provider = function(self)
                    if vim.api.nvim_buf_get_option(self.bufnr, "modified") then
                      return " ●"
                    elseif
                      not vim.api.nvim_buf_get_option(self.bufnr, "modifiable")
                      or vim.api.nvim_buf_get_option(self.bufnr, "readonly")
                    then
                      return " "
                    end
                  end,
                },
                { -- filename
                  provider = function(self)
                    local filename = self.filename
                    if filename == "" then
                      filename = " [No Name]"
                    else
                      filename = " " .. vim.fn.fnamemodify(filename, ":t")
                    end
                    return filename
                  end,
                },
              },
              { -- pad right
                provider = " ",
              },
            }),
          },
          { -- fill middle
            provider = "%=",
          },
          {
            condition = function()
              return require("dap").session() ~= nil
            end,
            provider = function()
              return " " .. require("dap").status()
            end,
            hl = "Debug",
            -- see Click-it! section for clickable actions
          },
        },
        opts = {
          disable_winbar_cb = function(args)
            return HIDE_BUFFERS
              or conditions.buffer_matches({
                buftype = { "nofile", "prompt", "help", "quickfix", "terminal" },
                filetype = { "^git.*", "noice" },
              }, args.buf)
          end,
        },
      })
    end,
  }),

  from_nixpkgs({
    "rebelot/kanagawa.nvim",
    event = "UIEnter",
    priority = 100,
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
          -- window separator
          WinSeparator = { fg = theme.ui.bg_dim, bg = theme.ui.bg_dim },
          NvimTreeNormal = { bg = theme.ui.bg_dim },
          -- nvim-tree
          NvimTreeGitDirty = { fg = theme.term[5], bg = "none" },
          NvimTreeGitStaged = { fg = theme.term[4], bg = "none" },
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
  }),

  from_nixpkgs({
    "echasnovski/mini.nvim",
    main = "mini.ai",
    name = "mini.ai",
    event = "VeryLazy",
    opts = {
      mappings = {
        around_last = "aN",
        inside_last = "iN",
      },
      custom_textobjects = {
        -- handled by treesitter
        a = false,
        f = false,
        -- change b from closing (with whitespace) to opening (without) braces
        b = { { "%b()", "%b[]", "%b{}" }, "^.%s*().-()%s*.$" },
        -- defaults include
        -- (, ), [, ], {, }, <, >, ", ', `, q, ?, t, <space>
      },
    },
    config = function(_, opts)
      require("mini.ai").setup(opts)
      for _, op in pairs({ "b", "(", ")", "[", "]", "{", "}", "<", ">", '"', "'", "`", "t", "<space>" }) do
        -- q is not in this list, it's for quickfix and only used as a textobject
        vim.keymap.set("n", "]" .. op, function()
          require("mini.ai").move_cursor("left", "i", op, { search_method = "next" })
        end, { desc = "Goto next start i" .. op .. " textobject" })
        vim.keymap.set("n", "[" .. op, function()
          require("mini.ai").move_cursor("left", "i", op, { search_method = "prev" })
        end, { desc = "Goto previous start i" .. op .. " textobject" })
      end
      vim.keymap.set("n", "]B", function()
        require("mini.ai").move_cursor("right", "i", "b", { search_method = "next" })
      end, { desc = "Goto next end ib textobject" })
      vim.keymap.set("n", "[B", function()
        require("mini.ai").move_cursor("right", "i", "b", { search_method = "prev" })
      end, { desc = "Goto previous end ib textobject" })
    end,
  }),

  from_nixpkgs({
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
  }),

  from_nixpkgs({
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
  }),

  from_nixpkgs({
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
          { mode = "n", keys = "<leader>m" },
          { mode = "x", keys = "<leader>m" },
          { mode = "n", keys = "<leader>d" },
          { mode = "x", keys = "<leader>d" },
          { mode = "n", keys = "<leader>g" },
          { mode = "x", keys = "<leader>g" },
          { mode = "n", keys = "<leader>o" },
          { mode = "x", keys = "<leader>o" },
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
          { mode = "n", keys = "<leader>mh", postkeys = "<leader>m" },
          { mode = "n", keys = "<leader>mj", postkeys = "<leader>m" },
          { mode = "n", keys = "<leader>mk", postkeys = "<leader>m" },
          { mode = "n", keys = "<leader>ml", postkeys = "<leader>m" },
          { mode = "x", keys = "<leader>mh", postkeys = "<leader>m" },
          { mode = "x", keys = "<leader>mj", postkeys = "<leader>m" },
          { mode = "x", keys = "<leader>mk", postkeys = "<leader>m" },
          { mode = "x", keys = "<leader>ml", postkeys = "<leader>m" },
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
  }),

  from_nixpkgs({
    "echasnovski/mini.nvim",
    main = "mini.comment",
    name = "mini.comment",
    event = "VeryLazy", -- event based, so the text object is also available from the start
    keys = {
      {
        "gcc",
        "gcl",
        desc = "comment current line",
      },
    },
    opts = {},
  }),

  from_nixpkgs({
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
  }),

  from_nixpkgs({
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
  }),

  from_nixpkgs({
    "echasnovski/mini.nvim",
    main = "mini.move",
    name = "mini.move",
    event = "VeryLazy", -- load on event for clue to work correctly
    keys = {
      { "<leader>m", "<nop>", { desc = "+move" } },
    },
    opts = {
      mappings = {
        left = "<leader>mh",
        right = "<leader>ml",
        down = "<leader>mj",
        up = "<leader>mk",
        line_left = "<leader>mh",
        line_right = "<leader>ml",
        line_down = "<leader>mj",
        line_up = "<leader>mk",
      },
    },
  }),

  from_nixpkgs({
    "echasnovski/mini.nvim",
    main = "mini.operators",
    name = "mini.operators",
    event = "InsertEnter",
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
  }),

  from_nixpkgs({
    "echasnovski/mini.nvim",
    main = "mini.pairs",
    name = "mini.pairs",
    event = "InsertEnter",
    opts = {},
  }),

  from_nixpkgs({
    "echasnovski/mini.nvim",
    main = "mini.pick",
    name = "mini.pick",
    event = "VeryLazy",
    keys = {
      {
        "<leader>f",
        function()
          require("mini.pick").builtin.files()
        end,
        desc = "find files",
      },
    },
    opts = {},
    config = function(_, opts)
      require("mini.pick").setup(opts)
      vim.ui.select = require("mini.pick").ui_select
    end,
  }),

  from_nixpkgs({
    "echasnovski/mini.nvim",
    main = "mini.splitjoin",
    name = "mini.splitjoin",
    keys = { "gS" },
    opts = {
      split = {
        hooks_post = {
          function()
            require("mini.splitjoin").gen_hook.add_trailing_separator({
              brackets = { "%b()", "%b[]", "%b{}" },
            })
          end,
        },
      },
      join = {
        hooks_post = {
          function()
            require("mini.splitjoin").gen_hook.del_trailing_separator({
              brackets = { "%b()", "%b[]", "%b{}" },
            })
          end,
        },
      },
    },
  }),

  from_nixpkgs({
    "echasnovski/mini.nvim",
    main = "mini.surround",
    name = "mini.surround",
    keys = { "s" },
    opts = {
      search_method = "cover_or_next",
    },
  }),

  from_nixpkgs({
    "echasnovski/mini.nvim",
    main = "mini.trailspace",
    name = "mini.trailspace",
    event = "InsertEnter",
    keys = {
      {
        "<leader>w",
        function()
          require("mini.trailspace").trim()
        end,
        desc = "trim trailing whitespace",
      },
    },
    opts = {},
  }),

  from_nixpkgs({
    "folke/noice.nvim",
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
    dependencies = { from_nixpkgs({ "MunifTanjim/nui.nvim" }) },
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
    config = function(_, opts)
      require("noice").setup(opts)
    end,
  }),

  from_nixpkgs({
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    dependencies = {
      from_nixpkgs({
        "junegunn/fzf",
        dir = vim.fn.stdpath("data") .. "/nixpkgs/fzf",
        name = "fzf",
        build = "./install --all",
      }),
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
  }),

  from_nixpkgs({
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      from_nixpkgs({ "hrsh7th/cmp-nvim-lsp" }),
      from_nixpkgs({ "dcampos/nvim-snippy" }),
      from_nixpkgs({ "dcampos/cmp-snippy" }),
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
  }),

  from_nixpkgs({
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
                  symbol.detail:sub(1, 4) == "func"
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
            -- dap.run(dap.configurations.go[1])
            -- return
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
      end
      dap.listeners.after.event_initialized["custom_maps"] = EnterDebugMode
      dap.listeners.before.event_terminated["custom_maps"] = ExitDebugMode
      dap.listeners.before.event_exited["custom_maps"] = ExitDebugMode
    end,
  }),

  from_nixpkgs({
    "mfussenegger/nvim-lint",
    event = "BufWritePre",
    opts = {
      bash = { "shellcheck" },
      go = { "golangcilint", "codespell" },
      -- markdown = { 'vale', 'languagetool', },
      nix = { "nix" },
      yaml = { "yamllint" },
    },
    config = function(_, opts)
      require("lint").linters_by_ft = opts
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  }),

  from_nixpkgs({
    "neovim/nvim-lspconfig",
    name = "lspconfig.gopls",
    ft = { "go", "gomod" },
    opts = {
      on_attach = function(client, bufnr)
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
  }),

  from_nixpkgs({
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
  }),

  from_nixpkgs({
    "neovim/nvim-lspconfig",
    name = "lspconfig.nil_ls",
    ft = { "nix" },
    opts = {},
    config = function(_, opts)
      require("lspconfig").nil_ls.setup(opts)
    end,
  }),

  from_nixpkgs({
    "neovim/nvim-lspconfig",
    name = "lspconfig.yamlls",
    ft = { "yaml" },
    opts = {
      settings = {
        yaml = {
          schemaStore = {
            enable = true,
            url = "https://www.schemastore.org/api/json/catalog.json",
          },
        },
      },
    },
    config = function(_, opts)
      require("lspconfig").yamlls.setup(opts)
    end,
  }),

  from_nixpkgs({
    "nvim-tree/nvim-tree.lua",
    keys = {
      {
        "-",
        function()
          local api = require("nvim-tree.api")
          if api.tree.is_visible() then
            api.tree.close()
          else
            api.tree.open()
            vim.cmd("wincmd p") -- no focus
          end
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
      -- utils used in below config
      local function buffers_only()
        if not require("nvim-tree.explorer.filters").config.filter_no_buffer then
          require("nvim-tree.explorer.filters").config.filter_no_buffer = true
          require("nvim-tree.actions.reloaders.reloaders").reload_explorer()
        end
      end
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
      api.events.subscribe(api.events.Event.TreeOpen, function(data)
        -- reset no_buffer filter
        buffers_only()
        -- expand all folders
        api.tree.expand_all()
        -- hide bufferbar
        HIDE_BUFFERS = true
        vim.schedule(function()
          vim.cmd.doautocmd("BufWinEnter")
        end)
        -- remap tab
        vim.keymap.set("n", "<tab>", function()
          buffers_only()
          api.tree.expand_all()
          local bufferlist, pos = get_buffers()
          if pos == #bufferlist then
            vim.cmd("buffer " .. bufferlist[1])
          else
            vim.cmd("buffer " .. bufferlist[pos + 1])
          end
        end, { silent = true, desc = "go to next buffer" })
        vim.keymap.set("n", "<s-tab>", function()
          buffers_only()
          api.tree.expand_all()
          local bufferlist, pos = get_buffers()
          if pos == 1 then
            vim.cmd("buffer " .. bufferlist[#bufferlist])
          else
            vim.cmd("buffer " .. bufferlist[pos - 1])
          end
        end, { silent = true, desc = "go to previous buffer" })
        -- keep tree live whatever
        vim.api.nvim_create_autocmd({ "BufReadPost", "BufNew" }, {
          group = vim.api.nvim_create_augroup("update_tree", { clear = true }),
          callback = function(ev)
            require("nvim-tree.actions.reloaders.reloaders").reload_explorer()
          end,
        })
      end)
      api.events.subscribe(api.events.Event.TreeClose, function(data)
        -- show bufferbar
        HIDE_BUFFERS = false
        vim.schedule(function()
          vim.cmd.doautocmd("BufWinEnter")
        end)
        -- delete update aucmd
        vim.api.nvim_del_augroup_by_name("update_tree")
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
          for i, w in ipairs(wins) do
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
  }),

  from_nixpkgs({
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
  }),

  from_nixpkgs({
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = from_nixpkgs({ "nvim-treesitter/nvim-treesitter" }),
    event = "VeryLazy",
  }),

  from_nixpkgs({
    "nvim-treesitter/nvim-treesitter-refactor",
    main = "nvim-treesitter.configs",
    dependencies = from_nixpkgs({ "nvim-treesitter/nvim-treesitter" }),
    event = "VeryLazy",
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
  }),

  from_nixpkgs({
    "nvim-treesitter/nvim-treesitter-textobjects",
    main = "nvim-treesitter.configs",
    dependencies = from_nixpkgs({ "nvim-treesitter/nvim-treesitter" }),
    event = "VeryLazy",
    opts = {
      textobjects = {
        lsp_interop = {
          enable = true,
          peek_definition_code = {
            ["gz"] = "@peek", -- replaces both from below
            ["gF"] = "@function.outer",
            ["gT"] = "@class.outer",
          },
        },
        swap = {
          enable = false,
        },
        select = {
          enable = true,
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
          enable = true,
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
  }),

  from_nixpkgs({
    "debugloop/telescope-undo.nvim",
    dependencies = {
      from_nixpkgs({
        "nvim-telescope/telescope.nvim",
        dependencies = {
          from_nixpkgs({ "nvim-lua/plenary.nvim" }),
        },
      }),
    },
    dev = false,
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
  }),
}
