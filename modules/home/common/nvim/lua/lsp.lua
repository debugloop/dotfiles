-- remove defaults
vim.keymap.del("n", "gO")
vim.keymap.del("n", "gra")
vim.keymap.del("n", "gri")
vim.keymap.del("n", "grn")
vim.keymap.del("n", "grr")
vim.keymap.del("n", "grt")

-- add my own
vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { desc = "lsp: rename symbol" })
vim.keymap.set({ "n", "x" }, "<leader>?", function()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  for _, lens in pairs(vim.lsp.codelens.get(0)) do
    if lens.range.start.line == (line - 1) and lens.command and lens.command.command ~= "" then
      vim.lsp.codelens.run()
      return
    end
  end
  vim.lsp.buf.code_action()
end, { desc = "lsp: run codelens or code action" })
vim.keymap.set({ "n", "x" }, "go", vim.lsp.buf.document_symbol, { desc = "lsp: show symbols" })
vim.keymap.set("n", "gO", vim.lsp.buf.workspace_symbol, { desc = "lsp: show workspacesymbols" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "lsp: show definition" })
vim.keymap.set("n", "gD", vim.lsp.buf.type_definition, { desc = "lsp: show type definition" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "lsp: show implementations" })
vim.keymap.set("n", "gr", function()
  vim.lsp.buf.references({ includeDeclaration = false })
end, { desc = "lsp: show references" })
vim.keymap.set("n", "gh", vim.lsp.buf.incoming_calls, { desc = "lsp: show callers" })
vim.keymap.set("n", "gH", vim.lsp.buf.outgoing_calls, { desc = "lsp: show callees" })
vim.keymap.set("n", "<leader>sd", vim.diagnostic.setqflist, { desc = "lsp: list diagnostics" })
vim.keymap.set("n", "<cr>", vim.lsp.buf.hover)

vim.lsp.enable(vim.tbl_map(function(f)
  return (f:gsub("%.lua$", ""))
end, vim.fn.readdir(vim.fn.stdpath("config") .. "/lsp")))
