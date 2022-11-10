require("which-key").setup({
  plugins = {
    spelling = {
      enabled = true,
      suggestions = 20,
    },
  },
})
require("which-key").register({
  g = { "git hydra" },
  d = { "debugger hydra" },
  o = { "options hydra" },
}, { prefix = "<leader>" })
