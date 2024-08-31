vim.opt.commentstring = "# %s"

-- indent
vim.opt.tabstop = 2
vim.opt.expandtab = true

-- lsp
vim.lsp.start({
  name = "nixd",
  cmd = { "nixd" },
  filetypes = { "nix" },
  single_file_support = true,
  root_dir = vim.fs.dirname(vim.fs.find({ "flake.nix", ".git/" }, { upward = true })[1]),
})
