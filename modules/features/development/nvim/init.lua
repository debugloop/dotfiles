require("aucmd")
require("options")
require("maps")

local plugins = require("plugins")

-- setup plugins using on-disk nixpkgs or vim.pack
for _, plugin in ipairs(plugins) do
  if type(plugin) == "table" and plugin.config then
    local function load()
      if plugin.src then
        vim.pack.add({ plugin.src }, { confirm = false })
      end
      plugin.config(plugin.opts or {})
    end
    if plugin.ft then
      vim.api.nvim_create_autocmd("FileType", {
        pattern = type(plugin.ft) == "string" and { plugin.ft } or plugin.ft,
        once = true,
        callback = load,
      })
    elseif plugin.event then
      vim.api.nvim_create_autocmd(
        type(plugin.event) == "string" and { plugin.event } or plugin.event,
        { once = true, callback = load }
      )
    elseif plugin.defer then
      vim.schedule(load)
    else
      load()
    end
  end
end

require("lsp")
