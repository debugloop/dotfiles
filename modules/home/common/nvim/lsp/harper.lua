local util = require("lsp_util")

---@type vim.lsp.Config
return {
  cmd = { "harper-ls", "--stdio" },
  filetypes = { "markdown" },
  root_dir = util.root_dir(),
  settings = {
    ["harper-ls"] = {
      linters = {
        SpellCheck = false,
        ToDoHyphen = false,
      },
    },
  },
}
