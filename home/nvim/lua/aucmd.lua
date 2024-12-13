-- add this functionality when LSP attaches
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("on_lsp_attach", {}),
  callback = function(event)
    -- commands
    vim.api.nvim_buf_create_user_command(event.buf, "LspFormat", function(_)
      vim.lsp.buf.format()
    end, { desc = "Format current buffer with LSP" })
    vim.api.nvim_buf_create_user_command(event.buf, "LspRestart", function(_)
      vim.lsp.stop_client(vim.lsp.get_clients())
      vim.cmd("edit")
    end, { desc = "Restart all active LSP clients" })

    -- mappings
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = event.buf, desc = "lsp: show definition" })
    vim.keymap.set("n", "<c-w>d", function()
      vim.cmd.vsplit()
      vim.lsp.buf.definition()
    end, { buffer = event.buf, desc = "lsp: show definition in new split" })
    vim.keymap.set("n", "gD", vim.lsp.buf.type_definition, { buffer = event.buf, desc = "lsp: show type definition" })
    vim.keymap.set("n", "gr", function()
      vim.lsp.buf.references({ includeDeclaration = false })
    end, { buffer = event.buf, desc = "lsp: show refs" })
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = event.buf, desc = "lsp: show implementations" })
    vim.keymap.set("n", "go", vim.lsp.buf.document_symbol, { buffer = event.buf, desc = "lsp: outline symbols" })
    vim.keymap.set("n", "<leader>qd", vim.diagnostic.setqflist, { buffer = event.buf, desc = "lsp: list diagnostics" })
    vim.keymap.set("n", "<leader>qD", function()
      vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.ERROR })
    end, { buffer = event.buf, desc = "lsp: list serious diagnostics" })
    vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { buffer = event.buf, desc = "lsp: rename symbol" })
    vim.keymap.set("n", "<leader>?", vim.lsp.buf.code_action, { buffer = event.buf, desc = "lsp: run code action" })
    vim.keymap.set("n", "<cr>", vim.diagnostic.open_float, { buffer = event.buf, desc = "lsp: open diagnostic" })
  end,
})

-- display help in a vertical split
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("vertical_help", { clear = true }),
  pattern = { "*.txt" },
  callback = function()
    if vim.o.filetype == "help" then
      vim.cmd.wincmd("L")
    end
  end,
})

-- auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = vim.api.nvim_create_augroup("auto_create_dir", { clear = true }),
  callback = function(event)
    local file = vim.loop.fs_realpath(event.match) or event.match ---@diagnostic disable-line: undefined-field vim.uv definitions are missing
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- close some buffers with q only
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("close_with_q", { clear = true }),
  pattern = {
    "help",
    "dap-float",
    "dap-preview",
    "git",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "startuptime",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>q<cr>", { buffer = event.buf, silent = true })
  end,
})

-- start with a fresh jumplist
vim.api.nvim_create_autocmd({ "VimEnter" }, {
  group = vim.api.nvim_create_augroup("on_startup", { clear = true }),
  pattern = "*",
  callback = function()
    vim.cmd("clearjumps")
  end,
})

-- do on entering insert mode
vim.api.nvim_create_autocmd({ "InsertEnter" }, {
  group = vim.api.nvim_create_augroup("on_insert_enter", { clear = true }),
  pattern = "*",
  callback = function()
    vim.opt.relativenumber = false -- switch to real line numbers
    vim.g.miniindentscope_disable = true -- disable indent guides
  end,
})

-- do on entering normal mode
vim.api.nvim_create_autocmd({ "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("on_insert_leave", { clear = true }),
  pattern = "*",
  callback = function(event)
    if vim.bo[event.buf].ft == "qf" then
      vim.opt.relativenumber = false
      return
    end
    vim.opt.relativenumber = true -- switch to relative line numbers
    vim.g.miniindentscope_disable = false -- re-enable indent guides
  end,
})

-- equalize windows on resize
vim.api.nvim_create_autocmd("VimResized", {
  group = vim.api.nvim_create_augroup("balance_splits", { clear = true }),
  callback = function()
    vim.cmd.tabdo("wincmd =")
  end,
})

-- flash yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ timeout = 300 })
  end,
})

-- tag initial buffers as persistent
vim.api.nvim_create_autocmd({ "VimEnter" }, {
  group = vim.api.nvim_create_augroup("persist_on_vim_open", { clear = true }),
  callback = function()
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      vim.fn.setbufvar(bufnr, "bufpersist", 1)
    end
  end,
})

-- autocmds for every buffer
vim.api.nvim_create_autocmd({ "BufRead" }, {
  group = vim.api.nvim_create_augroup("autocmd_on_buf_enter", { clear = true }),
  pattern = { "*" },
  callback = function(_)
    -- skip those on some filetypes
    if vim.o.filetype == "gitcommit" then
      return
    end
    -- mark as persisted
    vim.api.nvim_create_autocmd({ "InsertEnter", "BufModifiedSet" }, {
      buffer = 0,
      once = true,
      callback = function(_)
        vim.fn.setbufvar(0, "bufpersist", 1)
      end,
    })
    -- go to last loc when focusing a buffer the first time
    vim.api.nvim_create_autocmd("BufWinEnter", {
      buffer = 0,
      once = true,
      callback = function(_)
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] < lcount then
          pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
      end,
    })
  end,
})

-- terminals
vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("on_term_open", { clear = true }),
  pattern = "*",
  callback = function(_)
    vim.opt.relativenumber = false
  end,
})
vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter", "TermOpen" }, {
  group = vim.api.nvim_create_augroup("on_term_enter", { clear = true }),
  callback = function(event)
    if vim.startswith(vim.api.nvim_buf_get_name(event.buf), "term://") then
      vim.cmd.startinsert()
    end
  end,
})

-- highlight definitions (adapted from nvim-treesitter-refactor)
vim.g.disable_highlight_defs = false
local highlight_defs_augroup = vim.api.nvim_create_augroup("highlight_defs", { clear = true })
local highlight_defs = vim.api.nvim_create_namespace("nvim_treesitter_usages")
vim.api.nvim_create_autocmd({ "CursorHold" }, {
  group = highlight_defs_augroup,
  callback = function(event)
    if vim.g.disable_highlight_defs then
      return
    end
    local ts_utils = require("nvim-treesitter.ts_utils")
    local locals = require("nvim-treesitter.locals")
    local last_nodes = {}
    local node_at_point = ts_utils.get_node_at_cursor()
    -- Don't calculate usages again if we are on the same node.
    if
      node_at_point
      and node_at_point == last_nodes[event.buf]
      and #vim.api.nvim_buf_get_extmarks(event.buf, highlight_defs, 0, -1, {}) > 0
    then
      return
    else
      last_nodes[event.buf] = node_at_point
    end

    vim.api.nvim_buf_clear_namespace(event.buf, highlight_defs, 0, -1)
    if not node_at_point then
      return
    end

    local def_node, scope = locals.find_definition(node_at_point, event.buf)
    local usages = locals.find_usages(def_node, scope, event.buf)

    for _, usage_node in ipairs(usages) do
      if usage_node ~= node_at_point and usage_node ~= def_node then
        ts_utils.highlight_node(usage_node, event.buf, highlight_defs, "CurSearch")
      end
    end

    if def_node ~= node_at_point then
      ts_utils.highlight_node(def_node, event.buf, highlight_defs, "IncSearch")
    end
  end,
})
vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter" }, {
  group = highlight_defs_augroup,
  callback = function(event)
    vim.api.nvim_buf_clear_namespace(event.buf, highlight_defs, 0, -1)
  end,
})
