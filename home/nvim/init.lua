require("options")
require("maps")

if vim.g.vscode then
  vim.opt.loadplugins = false
  return
end

local lazypath = vim.fn.stdpath("data") .. "/nixpkgs/lazy-nvim"
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  defaults = {
    lazy = true,
  },
  dev = {
    path = "~/code",
    patterns = { "debugloop" },
  },
  diff = {
    cmd = "terminal_git",
  },
  checker = {
    enabled = false,
  },
  install = {
    colorscheme = { "kanagawa", "habamax" },
  },
  readme = {
    root = vim.fn.stdpath("data") .. "/lazy-readme",
  },
  state = vim.fn.stdpath("data") .. "/lazy-state.json",
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "netrw",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Manage plugins" })
