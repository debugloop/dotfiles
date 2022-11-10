require("options")
require("maps")

if vim.g.vscode then
  vim.opt.loadplugins = false
else
  require("plugins")
end
