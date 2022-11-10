require("lualine").setup({
  options = {
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    globalstatus = true,
    icons_enabled = false,
  },
  sections = {
    lualine_c = {
      { "filename", path = 1 },
    },
    lualine_x = {
      {
        "macro-recording",
        fmt = function()
          local recording_register = vim.fn.reg_recording()
          if recording_register == "" then
            return ""
          else
            return "recording @" .. recording_register
          end
        end,
        color = { fg = "orange" },
      },
      "encoding",
      "filetype",
    },
  },
  -- TODO: make full width available for tabline
  -- TODO: replace tabline with winbar eventually, right now it flickers
  tabline = {
    lualine_c = {
      {
        "buffers",
        buffers_color = {
          active = "Search",
        },
        symbols = {
          alternate_file = "",
        },
      },
    },
  },
})

vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
  group = vim.api.nvim_create_augroup("refresh_recording_indicator", {}),
  callback = function()
    require("lualine").refresh({ place = { "statusline" } })
  end,
})
