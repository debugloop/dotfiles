local util = require("lsp_util")

---@type vim.lsp.Config
return {
  init_options = {
    hostInfo = "neovim",
  },
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
  root_dir = util.root_dir(),
  single_file_support = true,
}
