local Hydra = require("hydra")

Hydra({
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
    {
      "q",
      nil,
      { exit = true, nowait = true, desc = false },
    },
    { "<Esc>", nil, { exit = true, nowait = true, desc = false } },
  },
})

Hydra({
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
    {
      "U",
      require("gitsigns").reset_buffer_index,
      { silent = true, nowait = true, desc = "unstage all" },
    },
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

Hydra({
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
