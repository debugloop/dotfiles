local util = require("lsp_util")

---@type vim.lsp.Config
return {
  cmd = { "fish-lsp", "start" },
  filetypes = { "fish" },
  root_dir = util.root_dir(),
}
