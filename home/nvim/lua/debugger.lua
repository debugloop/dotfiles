local M = {}
M = {
  namespace = vim.api.nvim_create_namespace("dap-view"),
  win = Snacks.win({
    enter = false,
    show = false,
    position = "bottom",
    height = 0.25,
    on_close = function()
      M.watched_expressions = {}
      M.expression_results = {}
      M.updated_evaluations = {}
    end,
    keys = {
      ["<cr>"] = function()
        local line = vim.api.nvim_win_get_cursor(0)[1]
        Snacks.win({
          position = "bottom",
          height = 0.25,
          width = 0.75,
          text = function()
            return M.expression_results[line]
          end,
        })
      end,
      ["d"] = function()
        local line = vim.api.nvim_win_get_cursor(0)[1]
        table.remove(M.watched_expressions, line)
        table.remove(M.expression_results, line)
        M._writeWindowContent()
      end,
      ["e"] = function()
        local line = vim.api.nvim_win_get_cursor(0)[1]
        local exp = vim.fn.input("Expression: ", M.watched_expressions[line])
        if exp == "" then
          return
        end
        M.watched_expressions[line] = exp
        M._evalExpression(exp, function(result)
          M.expression_results[line] = result
        end)
      end,
    },
  }),
  watched_expressions = {},
  expression_results = {},
  updated_evaluations = {},
}

local dap = require("dap")

local function split_string_to_table(str)
  local lines = {}
  for line in str:gmatch("([^\n]*)\n?") do
    if line ~= "" then
      table.insert(lines, line)
    end
  end
  return lines
end

M._writeWindowContent = function()
  if not M.win.buf then
    return
  end
  -- Clear previous content
  vim.api.nvim_buf_set_lines(M.win.buf, 0, -1, true, {})

  if #M.watched_expressions == 0 then
    vim.wo[M.win.win].cursorline = false
    vim.api.nvim_buf_set_lines(M.win.buf, 0, -1, false, { "No expressions" })
    return
  else
    vim.wo[M.win.win].cursorline = true
  end

  vim.api.nvim_buf_set_lines(M.win.buf, 0, #M.watched_expressions + 1, false, M.watched_expressions)

  for i = 1, #M.watched_expressions do
    local hl_group = M.updated_evaluations[i] and "DiagnosticVirtualTextWarn" or "Comment"
    local expr_result = M.expression_results[i]

    if expr_result then
      local split_lines = split_string_to_table(expr_result)
      local virt_lines = vim
        .iter(split_lines)
        :map(function(r)
          return { { r, hl_group } }
        end)
        :totable()

      if not vim.tbl_isempty(virt_lines) then
        vim.api.nvim_buf_set_extmark(M.win.buf, M.namespace, i - 1, 0, {
          virt_lines = virt_lines,
        })
      end
    end
  end
end

local function evalExpressionRecurse(prepend, result)
  local session = assert(require("dap").session(), "has active session")
  local frame_id = session.current_frame and session.current_frame.id

  local var_ref = result and result.variablesReference
  if var_ref and var_ref > 0 then
    local vars = {}

    local var_ref_err, var_ref_result =
      session:request("variables", { variablesReference = var_ref, context = "watch", frameId = frame_id })

    if var_ref_err then
      table.insert(vars, tostring(var_ref_err))
    end

    if var_ref_result and not var_ref_err then
      for _, k in pairs(var_ref_result.variables) do
        if k.name ~= "" then
          table.insert(vars, prepend .. k.name .. " = " .. k.value)
        end
        local appendable = evalExpressionRecurse(prepend .. " ", k)
        if appendable ~= "" then
          table.insert(vars, appendable)
        end
      end
    end
    return table.concat(vars, "\n")
  end
  return ""
end

M._evalExpression = function(expr, callback)
  local session = assert(require("dap").session(), "has active session")
  local frame_id = session.current_frame and session.current_frame.id

  coroutine.wrap(function()
    local err, result = session:request("evaluate", { expression = expr, context = "watch", frameId = frame_id })

    local expr_result = result and result.result or err and tostring(err):gsub("%s+", " ") or ""

    callback(expr_result .. evalExpressionRecurse(" ", result))
  end)()
end

M.add_expr = function()
  local exp = vim.fn.input("Expression: ")
  if exp == "" then
    exp = vim.fn.expand("<cexpr>")
  end
  M.add_watch_expr(exp)
  M.open()
end

M.add_watch_expr = function(expr)
  if not (#expr > 0 and not vim.tbl_contains(M.watched_expressions, expr)) then
    return
  end

  if not require("dap").session() then
    vim.notify("No active session")
    return
  end

  M._evalExpression(expr, function(result)
    table.insert(M.expression_results, result)
  end)

  table.insert(M.watched_expressions, expr)
end

M.open = function()
  M.win:show()
  M._writeWindowContent()
end

M.toggle = function()
  local win = M.win:toggle()
  if win:valid() then
    M._writeWindowContent()
  end
end

local SUBSCRIPTION_ID = "debugger"

dap.listeners.after.evaluate[SUBSCRIPTION_ID] = function()
  M._writeWindowContent()
end

dap.listeners.after.variables[SUBSCRIPTION_ID] = function()
  M._writeWindowContent()
end

dap.listeners.after.event_stopped[SUBSCRIPTION_ID] = function()
  for i, expr in ipairs(M.watched_expressions) do
    M._evalExpression(expr, function(result)
      M.updated_evaluations[i] = M.expression_results[i] and M.expression_results[i] ~= result
      M.expression_results[i] = result
    end)
  end
end

dap.listeners.after.event_terminated[SUBSCRIPTION_ID] = function()
  for k in ipairs(M.expression_results) do
    M.expression_results[k] = nil
  end
end

return M
