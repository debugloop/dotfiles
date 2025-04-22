vim.g.mapleader = " "

-- better up/down
vim.keymap.set("n", "j", [[ v:count > 1 ? "m'" . v:count . "j" : "gj" ]], { expr = true, silent = true })
vim.keymap.set("n", "k", [[ v:count > 1 ? "m'" . v:count . "k" : "gk" ]], { expr = true, silent = true })

-- smart beginning and end of line
vim.keymap.set("n", "H", function()
  local _, _, col, _ = unpack(vim.fn.getpos("."))
  vim.cmd("normal! ^")
  if col == vim.fn.getpos(".")[3] then
    vim.cmd("normal! 0")
  end
end, { desc = "go to start of line" })
vim.keymap.set({ "o", "x" }, "H", "^", { desc = "go to start of line" })
vim.keymap.set({ "n", "o", "x" }, "L", "$", { desc = "go to end of line" })

-- better paste
vim.keymap.set({ "n", "x" }, "<leader>p", function()
  vim.fn.setreg("+", vim.fn.getreg("+"), "V")
  vim.cmd.normal('"+p')
end, { desc = "paste as lines" })

-- jump back to last position
vim.keymap.set("n", "<bs>", "<c-o>", { desc = "jump backwards" })
vim.keymap.set("n", "<s-bs>", "<c-i>", { desc = "jump forwards" })
vim.keymap.set("n", "gl", function()
  local lcount = vim.api.nvim_buf_line_count(0)
  local last_change = vim.api.nvim_buf_get_mark(0, ".")
  if last_change[1] > 0 and last_change[1] <= lcount then
    pcall(vim.api.nvim_win_set_cursor, 0, last_change)
    return
  end
  local last_leave = vim.api.nvim_buf_get_mark(0, '"')
  if last_leave[1] > 0 and last_leave[1] <= lcount then
    pcall(vim.api.nvim_win_set_cursor, 0, last_leave)
    return
  end
end, { desc = "jump to last leave or last edit" })

-- move visual blocks
vim.keymap.set("x", "J", ":m '>+1<cr>gv=gv", { silent = true, desc = "move block down" })
vim.keymap.set("x", "K", ":m '<-2<cr>gv=gv", { silent = true, desc = "move block up" })

-- stay in visual after indent
vim.keymap.set("x", "<", "<gv", { desc = "deindent and reselect" })
vim.keymap.set("x", ">", ">gv", { desc = "indent and reselect" })

-- clear highlight
vim.keymap.set({ "n" }, "<esc>", "<cmd>nohl<cr><esc>", { desc = "escape and clear search" })

-- window movement
vim.keymap.set("n", "<c-h>", "<c-w>h", { desc = "move focus to left window" })
vim.keymap.set("n", "<c-j>", "<c-w>j", { desc = "move focus to window below" })
vim.keymap.set("n", "<c-k>", "<c-w>k", { desc = "move focus to window above" })
vim.keymap.set("n", "<c-l>", "<c-w>l", { desc = "move focus to right window" })

-- same for terminal and insert mode
vim.keymap.set({ "i", "t" }, "<c-h>", "<c-\\><c-n><c-w>h", { desc = "move focus to left window" })
vim.keymap.set({ "i", "t" }, "<c-j>", "<c-\\><c-n><c-w>j", { desc = "move focus to window below" })
vim.keymap.set({ "i", "t" }, "<c-k>", "<c-\\><c-n><c-w>k", { desc = "move focus to window above" })
vim.keymap.set({ "i", "t" }, "<c-l>", "<c-\\><c-n><c-w>l", { desc = "move focus to right window" })

-- window control for terminals
vim.keymap.set({ "t" }, "<c-w>", "<c-\\><c-n><c-w>", { desc = "window control" })

-- movement between buffers
vim.keymap.set("n", "<tab>", function()
  vim.cmd("bn")
end, { silent = true, desc = "go to next buffer" })
vim.keymap.set("n", "<s-tab>", function()
  vim.cmd("bp")
end, { silent = true, desc = "go to previous buffer" })
vim.keymap.set("n", "<leader>x", function()
  vim.notify("Clearing buffers...")
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if
      vim.bo[bufnr].buflisted
      and bufnr ~= vim.api.nvim_get_current_buf()
      and (vim.fn.getbufvar(bufnr, "bufpersist") ~= 1)
    then
      vim.cmd("bd " .. tostring(bufnr))
    end
  end
  pcall(vim.cmd.NvimTreeRefresh)
end, { desc = "close buffers not marked as persistent" })

-- banish weird default mappings
vim.keymap.set("n", "gQ", "<nop>") -- ex mode
vim.keymap.set({ "n", "x" }, "s", "<nop>") -- substitute char
vim.keymap.set("n", "S", "<nop>") -- substitute rest of line

-- indent on insert in empty lines
vim.keymap.set("n", "i", function()
  if #vim.fn.getline(".") == 0 then
    return [["_cc]]
  else
    return "i"
  end
end, { desc = "enter insert mode", expr = true })

-- no yank delete
vim.keymap.set("n", "dd", function()
  if vim.api.nvim_get_current_line():match("^%s*$") then
    return '"_dd'
  else
    return "dd"
  end
end, { desc = "delete line", expr = true })

-- no lsp defaults
vim.keymap.del("n", "gO")
vim.keymap.del("n", "gra")
vim.keymap.del("n", "gri")
vim.keymap.del("n", "grn")
vim.keymap.del("n", "grr")

-- open jumplist
vim.keymap.set("n", "<leader>sj", function()
  local has_snacks = pcall(require, "snacks")
  if has_snacks then
    Snacks.picker.jumps()
    return
  end
  local jumplist = vim.fn.getjumplist()[1]
  local qf_list = {}
  for _, v in ipairs(jumplist) do
    if vim.fn.bufloaded(v.bufnr) == 1 then
      table.insert(qf_list, {
        bufnr = v.bufnr,
        lnum = v.lnum,
        col = v.col,
        text = vim.api.nvim_buf_get_lines(v.bufnr, v.lnum - 1, v.lnum, false)[1],
      })
    end
  end
  vim.fn.setqflist(qf_list, " ")
  vim.cmd.cwindow()
end, { desc = "Jumplist" })

-- open changelist
vim.keymap.set("n", "<leader>sC", function()
  local qf_list = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local changelist = vim.fn.getchangelist()[1]
      local seen = {}
      for _, v in ipairs(changelist) do
        if not seen[v.lnum] then
          seen[v.lnum] = true
          table.insert(qf_list, {
            bufnr = buf,
            lnum = v.lnum,
            col = v.col,
            text = vim.api.nvim_buf_get_lines(buf, v.lnum - 1, v.lnum, false)[1],
          })
        end
      end
    end
  end
  vim.fn.setqflist(qf_list, " ")
  local has_snacks = pcall(require, "snacks")
  if has_snacks then
    Snacks.picker.qflist({ title = "Changelist" })
  else
    vim.cmd.cwindow()
  end
end, { desc = "Changelist" })

-- toggle quickfix
vim.keymap.set("n", "<leader><leader>", function()
  vim.cmd.cwindow()
end, { desc = "open quickfix" })

-- lsp
vim.keymap.set("n", "<cr>", vim.diagnostic.open_float, { desc = "lsp: open diagnostic" })
vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { desc = "lsp: rename symbol" })
vim.keymap.set("n", "<leader>?", vim.lsp.buf.code_action, { desc = "lsp: run code action" })
vim.keymap.set("n", "go", vim.lsp.buf.document_symbol, { desc = "lsp: show symbols" })
vim.keymap.set("n", "gO", vim.lsp.buf.workspace_symbol, { desc = "lsp: show workspacesymbols" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "lsp: show definition" })
vim.keymap.set("n", "gD", vim.lsp.buf.type_definition, { desc = "lsp: show type definition" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "lsp: show implementations" })
vim.keymap.set("n", "<leader>sd", vim.diagnostic.setqflist, { desc = "lsp: list diagnostics" })

vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Manage plugins" })
