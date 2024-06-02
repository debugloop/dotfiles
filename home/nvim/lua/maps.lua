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
vim.keymap.set({ "o", "v" }, "H", "^", { desc = "go to start of line" })
vim.keymap.set({ "n", "o", "v" }, "L", "$", { desc = "go to end of line" })

-- better paste
vim.keymap.set("n", "<leader>p", function()
  vim.fn.setreg("+", vim.fn.getreg("+"), "V")
  vim.cmd("normal p")
end, { desc = "paste as lines" })

-- live grep
vim.keymap.set("v", "<leader>*", function()
  local a_orig = vim.fn.getreg("a")
  local mode = vim.fn.mode()
  if mode ~= "v" and mode ~= "V" then
    vim.cmd([[normal! gv]])
  end
  vim.cmd([[silent! normal! "aygv]])
  local input = vim.fn.getreg("a")
  vim.fn.setreg("a", a_orig)
  if #input > 0 and not string.find(input, "\n") then
    vim.cmd('silent! grep! "' .. input .. '" | cwindow')
  end
end, { desc = "grep visual selecttion in project" })
vim.keymap.set("n", "<leader>*", function()
  local input = vim.fn.expand("<cword>")
  if #input > 0 then
    vim.cmd('silent! grep! "' .. input .. '" | cwindow')
  end
end, { desc = "grep cursor word in project" })
vim.keymap.set("n", "<leader>/", function()
  local input = vim.fn.input("grep: ")
  if #input > 0 then
    vim.cmd('silent! grep! "' .. input .. '" | cwindow')
  end
end, { desc = "grep in project" })

-- jump back to last position
vim.keymap.set("n", "<bs>", "<c-o>", { desc = "jump backwards" })
vim.keymap.set("n", "<s-bs>", "<c-i>", { desc = "jump forwards" })
vim.keymap.set("n", "gb", "<c-t>", { desc = "tagstack backwards" })
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

-- open fold
vim.keymap.set("n", "zi", "zA", { desc = "toggle fold" })
vim.keymap.set("n", "zI", "zXzO", { desc = "open fold and close others" })

-- move visual blocks
vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv", { silent = true, desc = "move block down" })
vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv", { silent = true, desc = "move block up" })

-- stay in visual after indent
vim.keymap.set("v", "<", "<gv", { desc = "deindent and reselct" })
vim.keymap.set("v", ">", ">gv", { desc = "indent and reselect" })

-- clear highlight
vim.keymap.set({ "n", "i" }, "<esc>", "<cmd>nohl<cr><esc>", { desc = "escape and clear search" })

-- fix Y map
vim.keymap.set("n", "Y", "y$", { desc = "escape and clear search" })

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

-- window resize
vim.keymap.set({ "n", "t" }, "<s-up>", "<cmd>resize +2<cr>", { desc = "resize height positive" })
vim.keymap.set({ "n", "t" }, "<s-down>", "<cmd>resize -2<cr>", { desc = "resize height negative" })
vim.keymap.set({ "n", "t" }, "<s-left>", "<cmd>vertical resize -2<cr>", { desc = "resize width negative" })
vim.keymap.set({ "n", "t" }, "<s-right>", "<cmd>vertical resize +2<cr>", { desc = "resize width positive" })

-- movement between buffers
vim.keymap.set("n", "<tab>", function()
  vim.cmd("bn")
end, { silent = true, desc = "go to next buffer" })
vim.keymap.set("n", "<s-tab>", function()
  vim.cmd("bp")
end, { silent = true, desc = "go to previous buffer" })
vim.keymap.set("n", "<leader>x", function()
  vim.print("Clearing buffers...")
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if
      vim.bo[bufnr].buflisted
      and bufnr ~= vim.api.nvim_get_current_buf()
      and (vim.fn.getbufvar(bufnr, "bufpersist") ~= 1)
    then
      vim.cmd("bd " .. tostring(bufnr))
    end
  end
  pcall(vim.cmd, "NvimTreeRefresh")
end, { desc = "close buffers not marked as persistent" })

-- copy git url
vim.keymap.set({ "n", "v" }, "gy", function()
  -- base
  local url = "https://github.com/"
  -- repo
  local repo = vim.fn.systemlist("git config --get remote.origin.url")[1]
  local repo_path = string.gsub(repo, "git@github%.com:?(.*)%.git", "%1")
  url = url .. repo_path .. "/blob/"
  -- revision
  local rev = vim.fn.systemlist("git rev-parse HEAD")[1]
  url = url .. rev .. "/"
  -- path
  local fullpath = vim.fn.expand("%:p")
  local gitroot = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  url = url .. fullpath:sub(#gitroot + 1, -1)
  -- lines
  local first, last
  if vim.fn.mode():lower() == "v" then
    first = vim.fn.getpos("v")[2]
    last = vim.fn.getpos(".")[2]
  else
    first = vim.fn.line(".")
    last = first
  end
  url = url .. "#L" .. first .. "-L" .. last
  vim.fn.setreg("+", url, "v")
end, { silent = true, desc = "copy git url" })

-- banish weird mappings
vim.keymap.set("n", "gQ", "<nop>") -- ex mode
vim.keymap.set("n", "s", "<nop>") -- substitute char
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
vim.keymap.set("n", "X", '"_d', { desc = "delete without yanking" })
vim.keymap.set("n", "XX", '"_dd', { desc = "delete line without yanking" })
vim.keymap.set("n", "dd", function()
  if vim.api.nvim_get_current_line():match("^%s*$") then
    return '"_dd'
  else
    return "dd"
  end
end, { desc = "delete line", expr = true })

-- open jumplist
vim.keymap.set("n", "<leader>qj", function()
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
end, { desc = "list jumplist" })

-- toggle quickfix
vim.keymap.set("n", "<leader><leader>", function()
  vim.cmd.cwindow()
end, { desc = "open quickfix" })

-- add undo state when inserting a newline
vim.keymap.set("i", "<cr>", "<cr><c-g>u")

-- always go forward using n, always go backward using N, independent of search with `/` or `?`
vim.keymap.set("n", "n", "'Nn'[v:searchforward]", { expr = true, desc = "next search result" })
vim.keymap.set("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "next search result" })
vim.keymap.set("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "next search result" })
vim.keymap.set("n", "N", "'nN'[v:searchforward]", { expr = true, desc = "prev search result" })
vim.keymap.set("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "prev search result" })
vim.keymap.set("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "prev search result" })

-- general LSP settings and maps
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_user_bindings", {}),
  callback = function(event)
    -- commands
    vim.api.nvim_buf_create_user_command(event.buf, "FormatLSP", function(_)
      vim.lsp.buf.format()
    end, { desc = "Format current buffer with LSP" })
    vim.api.nvim_buf_create_user_command(event.buf, "RestartLSP", function(_)
      vim.lsp.stop_client(vim.lsp.get_clients())
      vim.cmd("edit")
    end, { desc = "Restart all active LSP clients" })

    -- mappings
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = event.buf, desc = "lsp: show definition" })
    vim.keymap.set("n", "<c-w>d", function()
      vim.cmd("vsplit")
      vim.lsp.buf.definition()
    end, { buffer = event.buf, desc = "lsp: show definition in new split" })
    vim.keymap.set("n", "gD", vim.lsp.buf.type_definition, { buffer = event.buf, desc = "lsp: show type definition" })
    vim.keymap.set("n", "gr", function()
      vim.lsp.buf.references({ includeDeclaration = false })
    end, { buffer = event.buf, desc = "lsp: show refs" })
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = event.buf, desc = "lsp: show implementations" })
    vim.keymap.set("n", "go", vim.lsp.buf.document_symbol, { buffer = event.buf, desc = "lsp: outline symbols" })
    vim.keymap.set("n", "gq", vim.diagnostic.setqflist, { buffer = event.buf, desc = "lsp: list diagnostics" })
    vim.keymap.set("n", "<leader>qd", vim.diagnostic.setqflist, { buffer = event.buf, desc = "lsp: list diagnostics" })
    vim.keymap.set("n", "gQ", function()
      vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.ERROR })
    end, { buffer = event.buf, desc = "lsp: list serious diagnostics" })
    vim.keymap.set("n", "<leader>qD", function()
      vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.ERROR })
    end, { buffer = event.buf, desc = "lsp: list serious diagnostics" })
    vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { buffer = event.buf, desc = "lsp: rename symbol" })
    vim.keymap.set("n", "<leader>?", vim.lsp.buf.code_action, { buffer = event.buf, desc = "lsp: run code action" })
    vim.keymap.set("n", "<cr>", vim.diagnostic.open_float, { buffer = event.buf, desc = "lsp: open diagnostic" })
  end,
})
