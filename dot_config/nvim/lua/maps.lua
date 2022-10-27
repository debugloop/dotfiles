vim.g.mapleader = " "

-- smart beginning and end of line
vim.keymap.set("n", "H", function()
  local _, _, col, _ = unpack(vim.fn.getpos("."))
  vim.cmd("normal! ^")
  if col == vim.fn.getpos(".")[3] then
    vim.cmd("normal! 0")
  end
end)
vim.keymap.set({ "o", "v" }, "H", "^")
vim.keymap.set({ "n", "o", "v" }, "L", "$")

-- quickfix window navigation
vim.keymap.set("n", "<c-n>", "<cmd>cnext<cr>")
vim.keymap.set("n", "<c-m>", "<cmd>cprevious<cr>")
vim.keymap.set("n", "<c-q>", "<cmd>cclose<cr>")

-- jump back to last position
vim.keymap.set("n", "<bs>", "<c-o>")

-- move visual blocks
vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv", { silent = true })
vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv", { silent = true })

-- stay in visual after indent
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- clear highlight
vim.keymap.set("n", "<c-c>", ":nohl<cr>", { silent = true })

-- fix Y map
vim.keymap.set("n", "Y", "y$")

-- window movement
vim.keymap.set("n", "<c-h>", "<c-w>h")
vim.keymap.set("n", "<c-j>", "<c-w>j")
vim.keymap.set("n", "<c-k>", "<c-w>k")
vim.keymap.set("n", "<c-l>", "<c-w>l")

vim.keymap.set("n", "<left>", "<c-w>h")
vim.keymap.set("n", "<down>", "<c-w>j")
vim.keymap.set("n", "<up>", "<c-w>k")
vim.keymap.set("n", "<right>", "<c-w>l")

vim.keymap.set({ "n", "t" }, "<s-up>", "<cmd>resize +2<cr>")
vim.keymap.set({ "n", "t" }, "<s-down>", "<cmd>resize -2<cr>")
vim.keymap.set({ "n", "t" }, "<s-left>", "<cmd>vertical resize -2<cr>")
vim.keymap.set({ "n", "t" }, "<s-right>", "<cmd>vertical resize +2<cr>")

-- movement between buffers
vim.keymap.set("n", "<tab>", function()
  vim.cmd("bn")
end, { silent = true })
vim.keymap.set("n", "<s-tab>", function()
  vim.cmd("bp")
end, { silent = true })
vim.keymap.set("n", "<leader><tab>", "<cmd>bd<cr>")

-- jump to buffer
vim.keymap.set("n", "<leader>1", "<cmd>1b<cr>", { desc = "go to buffer 1" })
vim.keymap.set("n", "<leader>2", "<cmd>2b<cr>", { desc = "go to buffer 2" })
vim.keymap.set("n", "<leader>3", "<cmd>3b<cr>", { desc = "go to buffer 3" })
vim.keymap.set("n", "<leader>4", "<cmd>4b<cr>", { desc = "go to buffer 4" })
vim.keymap.set("n", "<leader>5", "<cmd>5b<cr>", { desc = "go to buffer 5" })
vim.keymap.set("n", "<leader>6", "<cmd>6b<cr>", { desc = "go to buffer 6" })
vim.keymap.set("n", "<leader>7", "<cmd>7b<cr>", { desc = "go to buffer 7" })
vim.keymap.set("n", "<leader>8", "<cmd>8b<cr>", { desc = "go to buffer 8" })
vim.keymap.set("n", "<leader>9", "<cmd>9b<cr>", { desc = "go to buffer 9" })
vim.keymap.set("n", "<leader>0", "<cmd>10b<cr>", { desc = "go to buffer 10" })

-- banish ex mode and silence E42
vim.keymap.set("n", "gQ", "<nop>")
vim.keymap.set("n", "<cr>", "j")

-- no yank delete
vim.keymap.set("n", "X", "'_d")
vim.keymap.set("n", "XX", "'_dd")

vim.keymap.set({ "i", "t" }, "<c-h>", "<c-\\><c-n><c-w>h")
vim.keymap.set({ "i", "t" }, "<c-j>", "<c-\\><c-n><c-w>j")
vim.keymap.set({ "i", "t" }, "<c-k>", "<c-\\><c-n><c-w>k")
vim.keymap.set({ "i", "t" }, "<c-l>", "<c-\\><c-n><c-w>l")

-- lsp mappings
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function()
    -- map lsp keys if attached only
    vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "lsp: show help", silent = true })
    vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "lsp: show references", silent = true })
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "lsp: goto definition", silent = true })
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "lsp: goto declaration", silent = true })
    vim.keymap.set("n", "<leader>s", vim.lsp.buf.document_symbol, { desc = "lsp: map all symbols", silent = true })
    vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { desc = "lsp: rename symbol", silent = true })
    vim.keymap.set("n", "<leader>?", vim.lsp.buf.code_action, { desc = "lsp: run code action", silent = true })
    vim.keymap.set("n", "]d", function()
      for _ = 1, vim.v.count1 do
        vim.diagnostic.goto_next()
      end
    end, { desc = "lsp: jump to next diagnostic", silent = true })
    vim.keymap.set("n", "[d", function()
      for _ = 1, vim.v.count1 do
        vim.diagnostic.goto_prev()
      end
    end, { desc = "lsp: jump to previous diagnostic", silent = true })
  end,
})
