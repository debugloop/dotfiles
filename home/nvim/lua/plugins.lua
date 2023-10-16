local function override_highlight(callback)
  callback()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("highlight_overrides", { clear = false }),
    pattern = "*",
    callback = callback,
  })
end

local function from_nixpkgs(spec)
  local name = spec[1]
  local plugin_name = name:match("[^/]+$")
  spec["dir"] = vim.fn.stdpath("data") .. "/nixpkgs/" .. plugin_name:gsub("%.", "-")
  return spec
end

return {
  -- {
  --   'Bekaboo/dropbar.nvim',
  --   event = "VeryLazy",
  -- },

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
        vim.keymap.set(
          "n",
          "<CR>",
          require("nvim-tree.api").node.open.edit,
          { desc = "nvim-tree: open", buffer = bufnr, noremap = true, silent = true, nowait = true }
        )
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
    "ruifm/gitlinker.nvim",
    keys = {
      {
        "gy",
        function()
          require("gitlinker").get_buf_range_url("n")
        end,
        desc = "copy github url",
        mode = "n",
      },
      {
        "gy",
        function()
          require("gitlinker").get_buf_range_url("v")
        end,
        desc = "copy github url",
        mode = "v",
      },
    },
    opts = {},
  }),

  from_nixpkgs({
    "lewis6991/gitsigns.nvim",
    lazy = false,
    -- event = "VeryLazy",
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
    "rebelot/kanagawa.nvim",
    event = "UIEnter",
    config = function(_, opts)
      require("kanagawa").setup(opts)
      require("kanagawa").load("wave")
    end,
    opts = {
      theme = "wave",
      dimInactive = true,
      globalStatus = true,
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
          -- telescope
          TelescopeTitle = { fg = theme.ui.special, bold = true },
          TelescopePromptNormal = { bg = theme.ui.bg_p1 },
          TelescopePromptCounter = { bg = theme.ui.bg_p1, fg = theme.ui.fg },
          TelescopePromptBorder = { fg = theme.ui.bg_p1, bg = theme.ui.bg_p1 },
          TelescopeResultsNormal = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m1 },
          TelescopeResultsBorder = { fg = theme.ui.bg_m1, bg = theme.ui.bg_m1 },
          TelescopePreviewNormal = { bg = theme.ui.bg },
          TelescopePreviewBorder = { bg = theme.ui.bg, fg = theme.ui.bg },
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

  from_nixpkgs({ "folke/lazy.nvim" }),

  from_nixpkgs({
    "echasnovski/mini.nvim",
    main = "mini.ai",
    name = "mini.ai",
    event = "VeryLazy",
    dependencies = {
      from_nixpkgs({
        "nvim-treesitter/nvim-treesitter-textobjects",
        dependencies = from_nixpkgs({ "nvim-treesitter/nvim-treesitter" }),
      }),
    },
    opts = {},
    config = function(_, opts)
      require("mini.ai").setup({
        mappings = {
          around_last = "",
          inside_last = "",
        },
        custom_textobjects = {
          a = require("mini.ai").gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),
          c = require("mini.ai").gen_spec.treesitter({ a = "@call.outer", i = "@call.inner" }),
          C = require("mini.ai").gen_spec.treesitter({ a = "@comment.outer", i = "@comment.inner" }),
          f = require("mini.ai").gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
          i = require("mini.ai").gen_spec.treesitter({ a = "@conditional.outer", i = "@conditional.inner" }),
          l = require("mini.ai").gen_spec.treesitter({ a = "@loop.outer", i = "@loop.inner" }),
          s = require("mini.ai").gen_spec.treesitter({ a = "@block.outer", i = "@block.inner" }),
          t = require("mini.ai").gen_spec.treesitter({ a = "@customtype.outer", i = "@customtype.inner" }),
        },
      })
    end,
  }),

  from_nixpkgs({
    "echasnovski/mini.nvim",
    main = "mini.animate",
    name = "mini.animate",
    event = "VeryLazy",
    opts = {},
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
      jump = { suffix = "", options = {} },
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
          -- maps that don't quit debug mode
          { mode = "n", keys = "<leader>dt", postkeys = "<leader>d" }, -- start
          { mode = "n", keys = "<leader>dT", postkeys = "<leader>d" }, -- start
          { mode = "n", keys = "<leader>dc", postkeys = "<leader>d" }, -- continue
          { mode = "n", keys = "<leader>ds", postkeys = "<leader>d" }, -- step over
          { mode = "n", keys = "<leader>dS", postkeys = "<leader>d" }, -- step back
          { mode = "n", keys = "<leader>di", postkeys = "<leader>d" }, -- step into
          { mode = "n", keys = "<leader>do", postkeys = "<leader>d" }, -- step out
          { mode = "n", keys = "<leader>dd", postkeys = "<leader>d" }, -- frame down
          { mode = "n", keys = "<leader>dr", postkeys = "<leader>d" }, -- restart
          { mode = "n", keys = "<leader>du", postkeys = "<leader>d" }, -- frame up
          -- maps that don't quit option mode (all of them)
          { mode = "n", keys = "<leader>ob", postkeys = "<leader>o" }, -- background
          { mode = "n", keys = "<leader>oc", postkeys = "<leader>o" }, -- conceal
          { mode = "n", keys = "<leader>oi", postkeys = "<leader>o" }, -- illuminate
          { mode = "n", keys = "<leader>oI", postkeys = "<leader>o" }, -- indentscope
          { mode = "n", keys = "<leader>ol", postkeys = "<leader>o" }, -- list
          { mode = "n", keys = "<leader>oL", postkeys = "<leader>o" }, -- LSP
          { mode = "n", keys = "<leader>on", postkeys = "<leader>o" }, -- number
          { mode = "n", keys = "<leader>or", postkeys = "<leader>o" }, -- relativenumber
          { mode = "n", keys = "<leader>os", postkeys = "<leader>o" }, -- spell
          { mode = "n", keys = "<leader>ot", postkeys = "<leader>o" }, -- treesitter context
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
    opts = {},
    config = function(opts)
      local MiniFiles = require("mini.files")
      MiniFiles.setup(opts)
      local go_in_edit = function(close)
        local fs_entry = MiniFiles.get_fs_entry()
        if fs_entry.fs_type ~= "file" then
          return MiniFiles.go_in()
        else
          vim.fn.win_execute(MiniFiles.get_target_window(), "edit " .. vim.fn.fnameescape(fs_entry.path))
        end
        if close then
          MiniFiles.close()
        end
      end
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          vim.keymap.set("n", "l", function()
            go_in_edit(false)
          end, { buffer = args.data.buf_id, desc = "Go in with edit" })
          vim.keymap.set("n", "L", function()
            go_in_edit(true)
          end, { buffer = args.data.buf_id, desc = "Go in and close with edit" })
        end,
      })
    end,
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
        object_scope = "iI",
        object_scope_with_border = "aI",
        goto_top = "[I",
        goto_bottom = "]I",
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
        prefix = "", -- disable
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
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
    config = function(_, opts)
      require("nvim-autopairs").setup(opts)

      -- for compatibility with zk-nvim [](( autocomplete trigger:
      -- TODO: get working
      -- local ts_conds = require("nvim-autopairs.ts-conds")
      -- require("nvim-autopairs").get_rule("["):with_pair(ts_conds.not_after_text("["))
    end,
  }),

  from_nixpkgs({
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      from_nixpkgs({ "hrsh7th/cmp-nvim-lsp" }),
      from_nixpkgs({ "hrsh7th/cmp-buffer" }),
      from_nixpkgs({ "windwp/nvim-autopairs" }),
      from_nixpkgs({ "dcampos/nvim-snippy" }),
      from_nixpkgs({ "dcampos/cmp-snippy" }),
      from_nixpkgs({ "echasnovski/mini.animate" }),
    },
    opts = function()
      require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end
      local cmp = require("cmp")
      local snippy = require("snippy")
      return {
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
                cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
              else
                fallback()
              end
            end,
            s = cmp.mapping.confirm({ select = true }),
          }),
        },
        sources = cmp.config.sources({
          { name = "snippy" },
          { name = "nvim_lsp" },
          { -- fallback
            { name = "buffer" },
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
        enabled = function()
          local context = require("cmp.config.context")
          return vim.api.nvim_get_mode().mode ~= "c"
              and not (context.in_treesitter_capture("comment") or context.in_syntax_group("Comment"))
        end,
      }
    end,
    config = function(_, opts)
      require("cmp").setup(opts)
      require("cmp").event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
      -- this makes the snippet mode not break when at the bottom of the screen:
      require("cmp").event:on("confirm_done", function()
        vim.g.minianimate_disable = false
      end)
      require("cmp").event:on("menu_closed", function()
        vim.g.minianimate_disable = false
      end)
      require("cmp").event:on("menu_opened", function()
        vim.g.minianimate_disable = true
      end)
    end,
  }),

  from_nixpkgs({
    "mfussenegger/nvim-dap",
    keys = {
      { "<leader>d", "<nop>", { desc = "+debug" } },
      {
        "<leader>dt",
        function()
          if not require("dap-go").debug_last_test() then
            require("dap-go").debug_test()
          end
        end,
        desc = "launch (last) test",
      },
      {
        "<leader>dT",
        function()
          require("dap-go").debug_test()
        end,
        desc = "launch test",
      },
      {
        "<leader>dr",
        function()
          require("dap").restart()
        end,
        desc = "restart",
      },
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "continue",
      },
      {
        "<leader>ds",
        function()
          require("dap").step_over()
        end,
        desc = "step",
      },
      {
        "<leader>dS",
        function()
          require("dap").step_back()
        end,
        desc = "step back",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "step into",
      },
      {
        "<leader>do",
        function()
          require("dap").step_out()
        end,
        desc = "step out",
      },
      {
        "<leader>dd",
        function()
          require("dap").down()
        end,
        desc = "frame down",
      },
      {
        "<leader>du",
        function()
          require("dap").up()
        end,
        desc = "frame up",
      },
      {
        "<leader>dK",
        function()
          require("dap.ui.widgets").hover(nil, { border = "rounded" })
        end,
        desc = "value under cursor",
      },
      {
        "<leader>de",
        function()
          require("dap.ui.widgets").preview(vim.fn.input("Expression: "))
          vim.keymap.set("n", "q", function()
            vim.cmd("pclose")
            vim.cmd("unmap q")
          end, { desc = "close preview" })
        end,
        desc = "evaluate",
      },
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "toggle breakpoint",
      },
      {
        "<leader>dB",
        function()
          local cond = vim.fn.input("Breakpoint condition or count: ")
          if tonumber(cond) ~= nil then
            vim.print("Breakpoint at visit #" .. cond)
            require("dap").set_breakpoint(nil, cond, nil)
          else
            vim.print("Breakpoint `if " .. cond .. "`")
            require("dap").set_breakpoint(cond, nil, nil)
          end
        end,
        desc = "toggle breakpoint",
      },
      {
        "<leader>dR",
        function()
          require("dap").repl.toggle()
          vim.cmd("wincmd j")
        end,
        desc = "toggle repl",
      },
      {
        "<leader>dq",
        function()
          require("dap").repl.close()
          require("dap").terminate()
        end,
        desc = "quit",
      },
      {
        "<leader>dQ",
        function()
          require("dap").repl.close()
          require("dap").terminate()
          require("dap").clear_breakpoints()
        end,
        desc = "quit",
      },
    },
    dependencies = {
      from_nixpkgs({
        "theHamsta/nvim-dap-virtual-text",
        dependencies = from_nixpkgs({ "mfussenegger/nvim-dap" }),
        opts = {
          commented = true,
        },
      }),
    },
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("on_dap_repl", { clear = true }),
        pattern = "dap-repl",
        callback = function()
          vim.cmd("startinsert")
        end,
      })
    end,
  }),

  from_nixpkgs({
    "leoluz/nvim-dap-go",
    ft = "go",
    dependencies = from_nixpkgs({ "mfussenegger/nvim-dap" }),
    opts = {},
    config = function()
      require("dap-go").setup({
        dap_configurations = {
          {
            type = "go",
            name = "Remote",
            mode = "remote",
            request = "attach",
            connect = {
              host = "127.0.0.1",
              port = "8181",
            },
            buildFlags = "-tags=unit,integration,e2e",
          },
          {
            type = "go",
            name = "Debug Package (Arguments)",
            request = "launch",
            program = "${fileDirname}",
            args = function()
              local args = {}
              vim.ui.input({ prompt = "Args: " }, function(input)
                args = vim.split(input or "", " ")
              end)
              return args
            end,
            buildFlags = "-tags=unit,integration,e2e",
          },
        },
        delve = {
          build_flags = "-tags=unit,integration,e2e",
        },
      })
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
    opts = {
      mode = "topline",
    },
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
            ["gF"] = "@function.outer",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]a"] = "@parameter.inner",
            ["]c"] = "@call.outer",
            ["]C"] = "@comment.outer",
            ["]f"] = "@function.outer",
            ["]i"] = "@conditional.outer",
            ["]l"] = "@loop.outer",
            ["]s"] = "@block.inner",
            ["]T"] = "@class.outer",
            ["]t"] = "@customtype.outer",
          },
          goto_next_end = {
            ["]A"] = "@parameter.inner",
            ["]F"] = "@function.outer",
            ["]L"] = "@loop.outer",
            ["]M"] = "@call.outer",
            ["]S"] = "@block.inner",
          },
          goto_previous_start = {
            ["[a"] = "@parameter.inner",
            ["[c"] = "@call.outer",
            ["[C"] = "@comment.outer",
            ["[f"] = "@function.outer",
            ["[i"] = "@conditional.outer",
            ["[l"] = "@loop.outer",
            ["[s"] = "@block.inner",
            ["[T"] = "@class.outer",
            ["[t"] = "@customtype.outer",
          },
          goto_previous_end = {
            ["[A"] = "@parameter.inner",
            ["[F"] = "@function.outer",
            ["[L"] = "@loop.outer",
            ["[M"] = "@call.outer",
            ["[S"] = "@block.inner",
          },
        },
        select = {
          enable = false,
        },
      },
    },
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
            shadow = true,
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
    "nvim-telescope/telescope.nvim",
    keys = {
      {
        "<leader>f",
        "<cmd>Telescope find_files<cr>",
        desc = "find files",
      },
      {
        "<leader>/",
        "<cmd>Telescope current_buffer_fuzzy_find<cr>",
        desc = "find matches",
      },
      {
        "<leader>s",
        "<cmd>Telescope live_grep<cr>",
        desc = "grep project",
      },
      {
        "<leader>*",
        "<cmd>Telescope grep_string<cr>",
        desc = "grep string in project",
        mode = "v",
      },
      {
        "<leader>*",
        "<cmd>Telescope grep_string<cr>",
        desc = "grep string in project",
      },
      {
        "<leader><leader>",
        "<cmd>Telescope resume<cr>",
        desc = "resume last telescope",
      },
      {
        "<leader>q",
        "<cmd>Telescope quickfix<cr>",
        desc = "resume from quickfix",
      },
      {
        "<leader><s-q>",
        "<cmd>Telescope quickfixhistory<cr>",
        desc = "resume from older quickfix",
      },
      {
        "<leader>b",
        "<cmd>Telescope buffers<cr>",
        desc = "find buffers",
      },
      {
        "gq",
        "<cmd>Telescope diagnostics<cr>",
        desc = "show diagnostics",
      },
      {
        "<leader>j",
        "<cmd>Telescope jumplist<cr>",
        desc = "find in jumplist",
      },
      {
        "<leader>gL",
        "<cmd>Telescope git_bcommits<cr>",
        desc = "find in git log",
      },
    },
    dependencies = {
      from_nixpkgs({ "nvim-lua/plenary.nvim" }),
      from_nixpkgs({ "nvim-telescope/telescope-fzf-native.nvim" }),
      from_nixpkgs({ "nvim-telescope/telescope-ui-select.nvim" }),
    },
    opts = {
      defaults = {
        sorting_strategy = "ascending",
        layout_strategy = "flex",
        layout_config = {
          prompt_position = "top",
        },
        dynamic_preview_title = true,
        prompt_title = false,
      },
      pickers = {
        buffers = {
          preview = {
            hide_on_startup = true,
          },
          theme = "dropdown",
        },
        diagnostics = {
          initial_mode = "normal",
        },
        lsp_references = {
          include_declaration = false,
          include_current_line = true,
        },
      },
    },
    config = function(_, opts)
      opts.defaults.mappings = {
        n = {
          ["<M-q>"] = false,
          ["q"] = require("telescope.actions").close,
          ["<esc>"] = require("telescope.actions").close,
          ["<c-q>"] = require("telescope.actions").smart_send_to_qflist,
          ["Q"] = require("telescope.actions").smart_send_to_qflist,
          ["H"] = false,
          ["M"] = false,
          ["L"] = false,
          ["<s-cr>"] = function()
            vim.cmd("startinsert!")
          end,
        },
        i = {
          ["<c-j>"] = require("telescope.actions").move_selection_next,
          ["<c-k>"] = require("telescope.actions").move_selection_previous,
          ["<c-q>"] = require("telescope.actions").smart_send_to_qflist,
          ["<c-cr>"] = require("telescope.actions").to_fuzzy_refine,
          ["<s-cr>"] = function()
            vim.cmd("stopinsert")
          end,
        },
      }
      require("telescope").setup(opts)
      require("telescope").load_extension("fzf")
      require("telescope").load_extension("ui-select")
      vim.api.nvim_create_autocmd("User", {
        group = vim.api.nvim_create_augroup("on_telescope_preview", { clear = true }),
        pattern = "TelescopePreviewerLoaded",
        callback = function(event)
          vim.opt_local.number = true
        end,
      })
    end,
  }),

  from_nixpkgs({
    "gbrlsnchs/telescope-lsp-handlers.nvim",
    dependencies = {
      from_nixpkgs({ "nvim-telescope/telescope.nvim" }),
    },
    event = "LspAttach",
    opts = {
      extensions = {
        lsp_handlers = {
          symbol = {
            telescope = {
              initial_mode = "normal",
            },
          },
          call_hierarchy = {
            telescope = {
              initial_mode = "normal",
            },
          },
          code_action = {
            telescope = {
              initial_mode = "normal",
            },
          },
          location = {
            telescope = {
              initial_mode = "normal",
              prompt_position = "bottom",
              fname_width = 64,
              path_display = {
                "truncate",
              },
            },
          },
        },
      },
    },
    config = function(_, opts)
      require("telescope").setup(opts)
      require("telescope").load_extension("lsp_handlers")
    end,
  }),

  from_nixpkgs({
    "debugloop/telescope-undo.nvim",
    dependencies = {
      from_nixpkgs({ "nvim-telescope/telescope.nvim" }),
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

  from_nixpkgs({
    "akinsho/toggleterm.nvim",
    keys = {
      {
        "<c-bs>",
        "<cmd>exe v:count1 . 'ToggleTerm direction=horizontal'<cr>",
        desc = "launch terminal",
        mode = { "n", "t" },
      },
      {
        "<c-cr>",
        "<cmd>exe v:count1 . 'ToggleTerm direction=vertical'<cr>",
        desc = "launch terminal vertical",
        mode = { "n", "t" },
      },
    },
    opts = {
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      shade_terminals = false,
      hide_numbers = false,
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)
      vim.api.nvim_create_autocmd("TermOpen", {
        group = vim.api.nvim_create_augroup("on_term", { clear = true }),
        pattern = "*",
        callback = function(event)
          vim.keymap.set("t", "<c-n>", [[<C-\><C-n>]], { buffer = event.buf })
          vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], { buffer = event.buf })
          vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], { buffer = event.buf })
          vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], { buffer = event.buf })
          vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], { buffer = event.buf })
          vim.opt.relativenumber = false
        end,
      })
    end,
  }),

  from_nixpkgs({
    "RRethy/vim-illuminate",
    event = "VeryLazy",
    keys = {
      {
        "<leader>i",
        function()
          require("illuminate").toggle()
        end,
        desc = "illuminate: toggle",
      },
      {
        "]]",
        function()
          for _ = 1, vim.v.count1 do
            require("illuminate").goto_next_reference()
          end
        end,
        desc = "illuminate: jump to next reference",
      },
      {
        "[[",
        function()
          for _ = 1, vim.v.count1 do
            require("illuminate").goto_prev_reference()
          end
        end,
        desc = "illuminate: jump to prev reference",
      },
    },
    opts = {
      providers = {
        "treesitter",
        "lsp", -- decreased priority, gopls does not differenciate reads and writes to refs
        "regex",
      },
      large_file_cutoff = 1000,
      large_file_overrides = {
        providers = {
          -- no "treesitter" here, it's to slow on large files
          "lsp", -- use lsp instead
          "regex",
        },
      },
      modes_allowlist = { "n" },
      filetypes_denylist = {
        "terminal",
        "dap-float",
        "dap-preview",
        "lspinfo",
        "minifiles",
        "man",
        "qf",
      },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)
      override_highlight(function()
        vim.api.nvim_set_hl(0, "IlluminatedWordRead", { link = "Visual" })
        vim.api.nvim_set_hl(0, "IlluminatedWordText", { link = "Visual" })
        vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { fg = "orange" })
      end)
    end,
  }),

  from_nixpkgs({
    "tpope/vim-sleuth",
    event = "BufReadPre",
  }),

  from_nixpkgs({
    "mickael-menu/zk-nvim",
    ft = "markdown",
    keys = {
      {
        "<leader>zo",
        function()
          require("zk").edit()
        end,
        desc = "open note",
      },
      {
        "<leader>zn",
        function()
          require("zk").new()
        end,
        desc = "new note",
      },
    },
    dependencies = {
      from_nixpkgs({ "nvim-telescope/telescope.nvim" }),
    },
    opts = {
      picker = "telescope",
    },
    config = function(_, opts)
      require("zk").setup(opts)
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("on_markdown_notes", { clear = true }),
        pattern = "markdown",
        callback = function(event)
          vim.opt_local.concealcursor = "n"
          if require("zk.util").notebook_root(vim.fn.expand("%:p")) ~= nil then
            vim.keymap.set("n", "<cr>", vim.lsp.buf.definition, { buffer = event.buf, desc = "open link" })
            vim.keymap.set("n", "<leader>zb", "<cmd>ZkBacklinks<cr>", { buffer = event.buf, desc = "find backlinks" })
            vim.keymap.set("n", "<leader>zl", "<cmd>ZkLinks<cr>", { buffer = event.buf, desc = "find links" })
          end
        end,
      })
    end,
  }),

  from_nixpkgs({
    "rebelot/heirline.nvim",
    event = "UIEnter",
    dependencies = { from_nixpkgs({ "rebelot/kanagawa.nvim" }) },
    config = function()
      vim.opt.showtabline = 0           -- no tabline ever
      vim.opt.laststatus = 2            -- windowed statusline
      vim.opt.showcmdloc = "statusline" -- enable partial command printing segment
      local conditions = require("heirline.conditions")
      local utils = require("heirline.utils")
      local colors = require("kanagawa.colors").setup()
      require("heirline").load_colors(colors)
      require("heirline").setup({
        tabline = {},
        statusline = {
          -- TODO: get a tab view in here
          static = {
            mode_colors_map = {
              n = require("lualine.themes.kanagawa").normal,
              i = require("lualine.themes.kanagawa").insert,
              v = require("lualine.themes.kanagawa").visual,
              ["\22"] = require("lualine.themes.kanagawa").visual,
              c = require("lualine.themes.kanagawa").command,
              s = require("lualine.themes.kanagawa").visual,
              r = require("lualine.themes.kanagawa").replace,
              t = require("lualine.themes.kanagawa").insert,
            },
            mode_color = function(self)
              if conditions.is_active() then
                return self.mode_colors_map[self.mode:lower()]
              else
                return {
                  a = "StatusLineNC",
                  b = "StatusLineNC",
                  c = "StatusLineNC",
                }
              end
            end,
          },
          {
            init = function(self)
              self.mode = vim.fn.mode()
              self.filename = vim.api.nvim_buf_get_name(0)
            end,
            { -- left section a
              hl = function(self)
                return self:mode_color().a
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
                    return "INACTIVE"
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
                return self:mode_color().b
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
                    hl = { fg = colors.theme.vcs.added },
                  },
                  {
                    provider = function(self)
                      local count = self.status_dict.changed or 0
                      return count > 0 and ("~" .. count .. " ")
                    end,
                    hl = { fg = colors.theme.vcs.changed },
                  },
                  {
                    provider = function(self)
                      local count = self.status_dict.removed or 0
                      return count > 0 and ("-" .. count .. " ")
                    end,
                    hl = { fg = colors.theme.vcs.removed },
                  },
                },
              },
              { -- lsp
                condition = function()
                  return conditions.is_active() and conditions.has_diagnostics()
                end,
                init = function(self)
                  self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
                  self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
                  self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
                  self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
                end,
                update = { "DiagnosticChanged", "BufEnter" },
                {
                  provider = " ",
                },
                {
                  provider = function(self)
                    return self.errors > 0 and ("E:" .. self.errors .. " ")
                  end,
                  hl = { fg = colors.theme.diag.error },
                },
                {
                  provider = function(self)
                    return self.warnings > 0 and ("W:" .. self.warnings .. " ")
                  end,
                  hl = { fg = colors.theme.diag.warn },
                },
                {
                  provider = function(self)
                    return self.info > 0 and ("I:" .. self.info .. " ")
                  end,
                  hl = { fg = colors.theme.diag.info },
                },
                {
                  provider = function(self)
                    return self.hints > 0 and ("H:" .. self.hints .. " ")
                  end,
                  hl = { fg = colors.theme.diag.hint },
                },
              },
            },
            { -- truncate marker
              provider = "%<",
            },
            { -- middle section c
              hl = function(self)
                return self:mode_color().c
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
                return self:mode_color().b
              end,
              {
                provider = " %p%%/%L ",
              },
            },
            { -- right section a
              hl = function(self)
                return self:mode_color().a
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
                    return "Search"
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
}
