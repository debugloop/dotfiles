local util = require("lsp_util")

---@type vim.lsp.Config
return {
  cmd = { "templ", "lsp" },
  filetypes = { "templ" },
  root_dir = util.root_dir({ "go.mod", "go.sum" }),
}
