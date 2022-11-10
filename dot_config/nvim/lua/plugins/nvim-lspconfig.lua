require("lspconfig")["gopls"].setup({
  on_attach = function(client, bufnr)
    -- automatic format on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("LspFormat", { clear = false }),
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ async = false }, 3000)
      end,
    })
    -- automatic organize imports on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("LspOrganizeImports", { clear = false }),
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
})
