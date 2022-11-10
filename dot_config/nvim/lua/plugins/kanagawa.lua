local default_colors = require("kanagawa.colors").setup()
require("kanagawa").setup({
  dimInactive = true,
  globalStatus = true,
  commentStyle = { italic = false },
  keywordStyle = { italic = false },
  variablebuiltinStyle = { italic = false },
  overrides = {
    -- fix Noice's cmdline borders
    DiagnosticInfo = { fg = default_colors.diag.info, bg = "bg" },
    DiagnosticWarn = { fg = default_colors.diag.warning, bg = "bg" },
    -- invisible separators
    WinSeparator = { fg = default_colors.bg_dim, bg = default_colors.bg_dim },
  },
})
vim.cmd("colorscheme kanagawa")
