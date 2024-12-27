-- indent
vim.opt.tabstop = 2
vim.opt.expandtab = true

-- lsp
vim.lsp.start({
  name = "lua_ls",
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_dir = vim.fs.dirname(vim.fs.find({ ".stylua.toml", ".git/" }, { upward = true })[1]),
  single_file_support = true,
  log_level = vim.lsp.protocol.MessageType.Warning,
  settings = {
    Lua = {
      telemetry = { enable = false },
      diagnostics = {
        disable = { "missing-fields" },
      },
    },
  },
})
