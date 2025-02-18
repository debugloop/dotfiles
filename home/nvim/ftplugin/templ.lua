vim.lsp.start({
  name = "templ",
  cmd = { "templ", "lsp" },
  filetypes = { "templ" },
  root_dir = vim.fs.dirname(vim.fs.find({ "go.mod", "go.sum", ".git/" }, { upward = true })[1]),
})
