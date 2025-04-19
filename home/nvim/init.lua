require("aucmd")
require("options")
require("maps")
require("lsp")

NIXPLUG_PATH = vim.fn.stdpath("data") .. "/nixpkgs"

local lazypath = NIXPLUG_PATH .. "/lazy-nvim"
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
  change_detection = {
    enabled = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
