local util = require("lsp_util")

---@type vim.lsp.Config
return {
  cmd = { "nixd" },
  filetypes = { "nix" },
  single_file_support = true,
  root_dir = util.root_dir(),
}
