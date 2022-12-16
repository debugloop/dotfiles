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
  modules = { "plugins" },
})
