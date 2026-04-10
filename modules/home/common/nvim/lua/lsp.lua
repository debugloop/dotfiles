-- remove defaults
vim.keymap.del("n", "gO")
vim.keymap.del("n", "gra")
vim.keymap.del("n", "gri")
vim.keymap.del("n", "grx")
vim.keymap.del("n", "grn")
vim.keymap.del("n", "grr")
vim.keymap.del("n", "grt")

vim.lsp.enable(vim.tbl_map(function(f)
  return (f:gsub("%.lua$", ""))
end, vim.fn.readdir(vim.fn.stdpath("config") .. "/lsp")))

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local buf = args.buf
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
    end

    map("n", "<leader>r", vim.lsp.buf.rename, "lsp: rename symbol")
    map({ "n", "x" }, "<leader>?", function()
      local line = vim.api.nvim_win_get_cursor(0)[1]
      for _, lens in pairs(vim.lsp.codelens.get({ bufnr = buf })) do
        if lens.lens.range.start.line == (line - 1) and lens.lens.command and lens.lens.command.command ~= "" then
          vim.lsp.codelens.run()
          return
        end
      end
      vim.lsp.buf.code_action()
    end, "lsp: run codelens or code action")
    map("n", "<cr>", vim.lsp.buf.hover, "lsp: hover")

    vim.lsp.codelens.enable(true, { bufnr = buf })
  end,
})

vim.api.nvim_create_autocmd("LspProgress", {
  ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
  callback = function(ev)
    local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
    vim.notify(vim.lsp.status(), vim.log.levels.INFO, {
      id = "lsp_progress",
      title = "LSP Progress",
      opts = function(notif)
        notif.icon = ev.data.params.value.kind == "end" and " "
          or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
      end,
    })
  end,
})
