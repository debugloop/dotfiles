local util = require("lsp_util")

---@type vim.lsp.Config
return {
  cmd = { "typos-lsp" },
  root_dir = util.root_dir(),
  single_file_support = true,
  init_options = {
    diagnosticSeverity = "hint",
  },
}
