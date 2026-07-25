local util = require("lsp_util")

---@type vim.lsp.Config
return {
  cmd = { "tinymist", "lsp" },
  filetypes = { "typst" },
  single_file_support = true,
  root_dir = util.root_dir({ "typst.toml", ".git/" }),
  on_attach = function(client, bufnr)
    vim.api.nvim_buf_create_user_command(bufnr, "Preview", function()
      client:exec_cmd({ command = "tinymist.startDefaultPreview", arguments = {} })
    end, {})
  end,
  settings = {
    preview = {
      background = {
        enabled = true,
        args = { "--data-plane-host=127.0.0.1:23635", "--invert-colors=never" },
      },
      browsing = {
        args = { "--data-plane-host=127.0.0.1:0", "--invert-colors=never", "--open" },
      },
    },
  },
}
