require("null-ls").setup({
  sources = {
    -- yaml and ansible
    -- require("null-ls").builtins.diagnostics.ansiblelint,
    require("null-ls").builtins.diagnostics.yamllint,
    -- lua
    require("null-ls").builtins.formatting.stylua,
    -- markdown and prose
    require("null-ls").builtins.diagnostics.vale,
    require("null-ls").builtins.hover.dictionary,
  },
})

-- autoformat lua on save
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    -- automatic format on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("LspFormat", { clear = true }),
      callback = function()
        vim.lsp.buf.format({ async = false }, 3000)
      end,
    })
  end,
})

-- start without diagnostics on markdown
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.diagnostic.disable(0)
    LspDisplay = 2
  end,
})

-- autodetect ansible
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "/home/danieln/playbook/**.yml",
  callback = function()
    vim.o.filetype = "yaml.ansible"
  end,
})
