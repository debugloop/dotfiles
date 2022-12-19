require("options")
require("maps")

if vim.g.vscode then
  vim.opt.loadplugins = false
  return
end

-- automatically install dep on startup
local path = vim.fn.stdpath("data") .. "/site/pack/deps/opt/dep"
if vim.fn.empty(vim.fn.glob(path)) > 0 then
  vim.fn.system({ "git", "clone", "--depth=1", "https://github.com/chiyadev/dep", path })
end
vim.cmd("packadd dep")

-- install all plugins
require("dep")({
  {
    "debugloop/telescope-undo.nvim",
    function()
      require("telescope").load_extension("undo")
      vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>")
    end,
    requires = { "nvim-telescope/telescope.nvim" },
  },
  modules = { "plugins" },
})

-- mkdir -p ~/.config/nvim/pack/plugins/opt/; ln -sf ~/code/telescope-undo.nvim ~/.config/nvim/pack/plugins/opt/telescope-undo.nvim
-- rm -r ~/.config/nvim/pack
-- vim.cmd("packadd telescope-undo.nvim")
-- require("telescope").load_extension("undo")
-- vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>")
