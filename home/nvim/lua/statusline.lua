local M = {}
local conditions = require("heirline.conditions")
local utils = require("heirline.utils")

M.static = {
  find_mode = function(self)
    if DEBUG_MODE then
      self.mode = "DEBUG_MODE"
    else
      self.mode = vim.fn.mode()
    end
  end,
  mode_colors = {
    n = "blue",
    i = "green",
    v = "purple",
    ["\22"] = "purple",
    c = "orange",
    s = "purple",
    r = "git_del",
    t = "green",
    debug_mode = "git_del",
  },
  color_a = function(self)
    if conditions.is_active() then
      return { fg = "bg", bg = self.mode_colors[self.mode:lower()] }
    else
      return "StatusLineNC"
    end
  end,
  color_b = function(self)
    if conditions.is_active() then
      return { fg = self.mode_colors[self.mode:lower()] }
    else
      return "StatusLineNC"
    end
  end,
  color_c = function(_)
    if conditions.is_active() then
      return "StatusLine"
    else
      return "StatusLineNC"
    end
  end,
}

M.colors = {
  bg = utils.get_highlight("StatusLine").bg,
  fg = utils.get_highlight("StatusLine").fg,
  bright_bg = utils.get_highlight("Folded").bg,
  bright_fg = utils.get_highlight("Folded").fg,
  red = utils.get_highlight("DiagnosticError").fg,
  green = utils.get_highlight("String").fg,
  blue = utils.get_highlight("Function").fg,
  orange = utils.get_highlight("Constant").fg,
  purple = utils.get_highlight("Statement").fg,
  diag_warn = utils.get_highlight("DiagnosticWarn").fg,
  diag_error = utils.get_highlight("DiagnosticError").fg,
  diag_hint = utils.get_highlight("DiagnosticHint").fg,
  diag_info = utils.get_highlight("DiagnosticInfo").fg,
  git_del = utils.get_highlight("diffDeleted").fg,
  git_add = utils.get_highlight("diffAdded").fg,
  git_change = utils.get_highlight("diffChanged").fg,
}

M.components = {}

M.components.space = {
  provider = " ",
}

M.components.truncate = {
  provider = "%<",
}

M.components.fill = {
  provider = "%=",
}

M.components.mode = {
  static = {
    mode_names = {
      n = "NORMAL",
      v = "VISUAL",
      V = "V-LINE",
      ["\22"] = "V-BLOCK",
      i = "INSERT",
      R = "REPLACE",
      c = "COMMAND",
      t = "TERMINAL",
      s = "SNIPPET",
    },
  },
  provider = function(self)
    if not conditions.is_active() then
      return " INACTIVE "
    end
    if DEBUG_MODE then
      return " DEBUG "
    end
    local name = self.mode_names[self.mode]
    if name == "" or name == nil then
      name = vim.fn.mode(true)
    end
    return " " .. name .. " "
  end,
}

M.components.branch = {
  flexible = 20,
  {
    provider = function(_)
      return "  " .. vim.b.gitsigns_status_dict.head .. " "
    end,
  },
  {
    provider = function(_)
      return " " .. vim.b.gitsigns_status_dict.head
    end,
  },
}

M.components.changes = {
  init = function(self)
    self.has_changes = vim.b.gitsigns_status_dict.added ~= 0
      or vim.b.gitsigns_status_dict.removed ~= 0
      or vim.b.gitsigns_status_dict.changed ~= 0
  end,
  condition = function(_)
    return conditions.is_active()
  end,
  {
    condition = function(self)
      return self.has_changes
    end,
    provider = " ",
    {
      provider = function(_)
        local count = vim.b.gitsigns_status_dict.added or 0
        return count > 0 and ("+" .. count .. " ")
      end,
      hl = { fg = "git_add" },
    },
    {
      provider = function(_)
        local count = vim.b.gitsigns_status_dict.changed or 0
        return count > 0 and ("~" .. count .. " ")
      end,
      hl = { fg = "git_change" },
    },
    {
      provider = function(_)
        local count = vim.b.gitsigns_status_dict.removed or 0
        return count > 0 and ("-" .. count .. " ")
      end,
      hl = { fg = "git_del" },
    },
  },
}

M.components.git = {
  condition = conditions.is_git_repo,
  M.components.branch,
  M.components.changes,
}

M.components.lsp = {
  condition = function()
    return conditions.is_active() and conditions.has_diagnostics()
  end,
  init = function(self)
    self.errors = #vim.diagnostic.get(0, {
      severity = vim.diagnostic.severity.ERROR,
    })
    self.warnings = #vim.diagnostic.get(0, {
      severity = vim.diagnostic.severity.WARN,
    })
    self.hints = #vim.diagnostic.get(0, {
      severity = vim.diagnostic.severity.HINT,
    })
    self.info = #vim.diagnostic.get(0, {
      severity = vim.diagnostic.severity.INFO,
    })
  end,
  update = { "DiagnosticChanged", "BufEnter" },
  {
    provider = " ",
  },
  {
    provider = function(self)
      return self.errors > 0 and ("E:" .. self.errors .. " ")
    end,
    hl = { fg = "diag_error" },
  },
  {
    provider = function(self)
      return self.warnings > 0 and ("W:" .. self.warnings .. " ")
    end,
    hl = { fg = "diag_warn" },
  },
  {
    provider = function(self)
      return self.info > 0 and ("I:" .. self.info .. " ")
    end,
    hl = { fg = "diag_info" },
  },
  {
    provider = function(self)
      return self.hints > 0 and ("H:" .. self.hints .. " ")
    end,
    hl = { fg = "diag_hint" },
  },
}

M.components.filename = {
  flexible = 50,
  {
    provider = function(self)
      local fqn = vim.fn.fnamemodify(self.filename, ":.")
      if fqn:sub(1, 1) ~= "/" then
        return "./" .. fqn
      else
        return fqn
      end
    end,
  },
  {
    provider = function(self)
      return vim.fn.fnamemodify(self.filename, ":.")
    end,
  },
  {
    provider = function(self)
      return vim.fn.pathshorten(vim.fn.fnamemodify(self.filename, ":."))
    end,
  },
}

M.components.macro = {
  hl = { fg = "orange" },
  condition = function()
    return conditions.is_active() and vim.fn.reg_recording() ~= "" and vim.o.cmdheight == 0
  end,
  provider = function()
    return " @" .. vim.fn.reg_recording()
  end,
  update = {
    "RecordingEnter",
    "RecordingLeave",
  },
}

M.components.filetype = {
  provider = function()
    return " " .. vim.bo.filetype .. " "
  end,
}

M.components.encoding = {
  provider = function()
    local enc = (vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc
    return enc ~= "utf-8" and enc .. " "
  end,
}

M.components.fileformat = {
  provider = function()
    local fmt = vim.bo.fileformat
    return fmt ~= "unix" and fmt .. " "
  end,
}

M.components.ruler = {
  provider = " %p%%/%L ",
}

M.components.linecol = {
  provider = " %l:%v ",
}

M.components.bufmark = {
  provider = function(self)
    if vim.api.nvim_buf_get_option(self.bufnr, "modified") then
      return "● "
    elseif
      not vim.api.nvim_buf_get_option(self.bufnr, "modifiable")
      or vim.api.nvim_buf_get_option(self.bufnr, "readonly")
    then
      return " "
    else
      return ""
    end
  end,
}

M.components.bufname = {
  provider = function(self)
    local fname = self.filename
    if fname == "" then
      fname = "[No Name]"
    else
      fname = vim.fn.fnamemodify(fname, ":t")
    end
    return fname
  end,
}

M.components.dap = {
  condition = function()
    return require("dap").session() ~= nil
  end,
  provider = function()
    return " " .. require("dap").status()
  end,
  hl = "Debug",
}

return M
