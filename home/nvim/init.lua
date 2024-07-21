require("aucmd")
require("options")
require("maps")

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
  },
  diff = {
    cmd = "terminal_git",
  },
  checker = {
    enabled = false,
  },
  change_detection = {
    enabled = false,
  },
  install = {
    colorscheme = { "catppuccin", "zaibatsu" },
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
