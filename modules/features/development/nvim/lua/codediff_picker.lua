local M = {}
local lifecycle = require("codediff.ui.lifecycle")

function M.open()
  local tabpage = vim.api.nvim_get_current_tabpage()
  local explorer = lifecycle.get_panel_view(tabpage)
  if lifecycle.get_panel_name(tabpage) ~= "explorer" or not explorer then
    return
  end
  local files = {}
  local selected = explorer.data.current_selection or {}
  for _, node in ipairs(explorer.tree:get_nodes()) do
    for _, file in ipairs(node.data.files) do
      if file.path ~= selected.path or node.data.name ~= selected.group then
        files[#files + 1] = vim.tbl_extend("force", file, {
          group = node.data.name,
          file = file.path,
          cwd = explorer.data.git_root or explorer.data.dir2,
        })
      end
    end
  end
  return require("snacks").picker.select(files, {
    prompt = "Diff files",
    format_item = function(file)
      return file.path .. " [" .. file.group .. "]"
    end,
    snacks = {
      layout = "buffers",
      preview = "file",
      auto_confirm = true,
      win = { input = { keys = { ["<c-space>"] = { "cancel", mode = { "i", "n" } } } } },
    },
  }, function(file)
    if file then
      explorer.on_file_select(file)
    end
  end)
end

function M.setup()
  local function register()
    local tabpage = vim.api.nvim_get_current_tabpage()
    if lifecycle.get_panel_name(tabpage) == "explorer" then
      lifecycle.set_tab_keymap(tabpage, "n", "<leader>t", M.open, { desc = "Diff files" })
    end
  end
  local group = vim.api.nvim_create_augroup("codediff_file_picker", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = { "CodeDiffOpen", "CodeDiffFileSelect" },
    callback = vim.schedule_wrap(register),
  })
  vim.api.nvim_create_autocmd("BufEnter", { group = group, callback = register })
  register()
end

return M
