local util = require("lsp_util")

---@type vim.lsp.Config
return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_dir = util.root_dir({ ".stylua.toml" }),
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
}
