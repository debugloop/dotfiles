-- display help in a vertical split
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("vertical_help", { clear = true }),
  pattern = { "*.txt", "*.md" },
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
    if vim.fn.argc() > 1 then
      vim.cmd.blast()
      vim.cmd.bfirst()
    end
  end,
})

-- do on entering insert mode
vim.api.nvim_create_autocmd({ "InsertEnter" }, {
  group = vim.api.nvim_create_augroup("on_insert_enter", { clear = true }),
  pattern = "*",
  callback = function(event)
    if vim.bo[event.buf].ft:match("snacks.*") then
      return
    end
    vim.opt.relativenumber = false -- switch to real line numbers
  end,
})

-- do on entering normal mode
vim.api.nvim_create_autocmd({ "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("on_insert_leave", { clear = true }),
  pattern = "*",
  callback = function(event)
    if vim.bo[event.buf].ft:match("snacks.*") or vim.bo[event.buf].ft == "minifiles" then
      return
    end
    if vim.bo[event.buf].ft == "qf" then
      vim.opt.relativenumber = false
      return
    end
    vim.opt.relativenumber = true -- switch to relative line numbers
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
  group = vim.api.nvim_create_augroup("add_autocmd_on_buf_enter", { clear = true }),
  pattern = { "*" },
  callback = function(openEvent)
    if vim.o.filetype == "gitcommit" then
      vim.cmd.normal("1G0") -- discard any position there might be on file
      return -- skip the usual things
    end
    -- mark as persisted
    vim.api.nvim_create_autocmd({ "InsertEnter", "BufModifiedSet" }, {
      buffer = openEvent.buf,
      once = true,
      callback = function(event)
        vim.fn.setbufvar(event.buf, "bufpersist", 1)
      end,
    })
  end,
})

-- go to last loc when focusing a buffer the first time
vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("restore_position", { clear = true }),
  callback = function(event)
    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    local lcount = vim.api.nvim_buf_line_count(event.buf)
    if mark[1] > 0 and mark[1] < lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- terminals
vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("on_term_open", { clear = true }),
  pattern = "*",
  callback = function(_)
    vim.opt.relativenumber = false
    vim.cmd.startinsert()
  end,
})
