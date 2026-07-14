local M = {}

local function bufnr(p)
	if p and p.buffer then
		return p.buffer
	end
	return vim.api.nvim_get_current_buf()
end

local function winid()
	return vim.api.nvim_get_current_win()
end

local function file_of(buf)
	return vim.api.nvim_buf_get_name(buf)
end

local function pos(line, col0)
	return { line = line, column = (col0 or 0) + 1, columnBase = 1, columnUnit = "byte" }
end

local function range_from0(sl0, sc0, el0, ec0)
	return { start = pos(sl0 + 1, sc0), ["end"] = pos(el0 + 1, ec0) }
end

local function visible_range()
	return { startLine = vim.fn.line("w0"), endLine = vim.fn.line("w$") }
end

local function loaded_buffers()
	local out = {}
	for _, b in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(b) then
			table.insert(out, {
				buffer = b,
				file = vim.api.nvim_buf_get_name(b),
				modified = vim.bo[b].modified,
				loaded = true,
				listed = vim.bo[b].buflisted,
				lineCount = vim.api.nvim_buf_line_count(b),
			})
		end
	end
	return out
end

local function active_selection(buf)
	local m = vim.fn.mode()
	if m ~= "v" and m ~= "V" and m ~= "\022" then
		return nil
	end
	local a = vim.fn.getpos("v")
	local c = vim.api.nvim_win_get_cursor(0)
	local sl, sc = a[2], a[3]
	local el, ec = c[1], c[2] + 1
	if sl > el or (sl == el and sc > ec) then
		sl, el = el, sl
		sc, ec = ec, sc
	end
	return {
		mode = (m == "V" and "line" or (m == "\022" and "block" or "char")),
		start = { line = sl, column = sc, columnBase = 1, columnUnit = "byte" },
		["end"] = { line = el, column = ec, columnBase = 1, columnUnit = "byte" },
	}
end

local function selection_text(buf, sel)
	if not sel then
		return nil
	end
	if sel.mode == "line" then
		return table.concat(vim.api.nvim_buf_get_lines(buf, sel.start.line - 1, sel["end"].line, false), "\n")
	end
	local ok, lines = pcall(
		vim.api.nvim_buf_get_text,
		buf,
		sel.start.line - 1,
		math.max(sel.start.column - 1, 0),
		sel["end"].line - 1,
		sel["end"].column,
		{}
	)
	if not ok then
		return nil
	end
	return table.concat(lines, "\n")
end

local function diagnostic_items(buf, startLine, endLine)
	local opts = { bufnr = buf }
	local diags = vim.diagnostic.get(buf)
	local severity_names = { [1] = "error", [2] = "warning", [3] = "info", [4] = "hint" }
	local out, counts = {}, { error = 0, warning = 0, info = 0, hint = 0 }
	for _, d in ipairs(diags) do
		local line = d.lnum + 1
		if (not startLine or line >= startLine) and (not endLine or line <= endLine) then
			local sev = severity_names[d.severity] or tostring(d.severity)
			counts[sev] = (counts[sev] or 0) + 1
			table.insert(out, {
				file = vim.api.nvim_buf_get_name(buf),
				line = line,
				column = (d.col or 0) + 1,
				endLine = (d.end_lnum or d.lnum) + 1,
				endColumn = (d.end_col or d.col or 0) + 1,
				severity = sev,
				source = d.source,
				message = d.message,
				code = d.code,
			})
		end
	end
	return out, counts
end

local function node_name(buf, node)
	if not node then
		return nil
	end
	local ok_name, fields = pcall(function()
		return node:field("name")
	end)
	if ok_name and fields and fields[1] then
		local ok_text, text = pcall(vim.treesitter.get_node_text, fields[1], buf)
		if ok_text then
			return text
		end
	end
	return nil
end

local function syntax_context(buf)
	if not vim.treesitter or not vim.treesitter.get_node then
		return nil
	end
	local ok, node = pcall(vim.treesitter.get_node, { bufnr = buf })
	if not ok or not node then
		return nil
	end
	local ancestors = {}
	local symbol = nil
	while node do
		local sr, sc, er, ec = node:range()
		local item = { type = node:type(), name = node_name(buf, node), range = range_from0(sr, sc, er, ec) }
		table.insert(ancestors, item)
		if
			not symbol
			and (
				item.name
				or item.type:match("function")
				or item.type:match("method")
				or item.type:match("class")
				or item.type:match("test")
				or item.type:match("component")
			)
		then
			symbol = { kind = item.type, name = item.name, range = item.range }
		end
		node = node:parent()
	end
	return { syntaxAncestors = ancestors, symbolAtCursor = symbol }
end

local function brief()
	local buf = vim.api.nvim_get_current_buf()
	local cur = vim.api.nvim_win_get_cursor(0)
	local sel = active_selection(buf)
	return {
		server = vim.v.servername,
		cwd = vim.fn.getcwd(),
		mode = vim.fn.mode(),
		current = {
			window = vim.api.nvim_get_current_win(),
			buffer = buf,
			file = vim.api.nvim_buf_get_name(buf),
			modified = vim.bo[buf].modified,
			cursor = pos(cur[1], cur[2]),
			visibleRange = visible_range(),
			selection = sel,
		},
		buffers = loaded_buffers(),
	}
end

function M.get_state_brief(p)
	return brief()
end

function M.get_state(p)
	p = p or {}
	local context = p.contextLines or 20
	local s = brief()
	local buf = s.current.buffer
	local cursorLine = s.current.cursor.line
	local lineCount = vim.api.nvim_buf_line_count(buf)
	local surroundingStart = math.max(1, cursorLine - context)
	local surroundingEnd = math.min(lineCount, cursorLine + context)
	local vis = s.current.visibleRange
	local sel = s.current.selection
	if sel then
		sel.text = selection_text(buf, sel)
	end
	s.current.cursorLineText = (vim.api.nvim_buf_get_lines(buf, cursorLine - 1, cursorLine, false)[1] or "")
	s.current.surroundingLines = {
		startLine = surroundingStart,
		lines = vim.api.nvim_buf_get_lines(buf, surroundingStart - 1, surroundingEnd, false),
	}
	s.current.visibleLines =
		{ startLine = vis.startLine, lines = vim.api.nvim_buf_get_lines(buf, vis.startLine - 1, vis.endLine, false) }
	local diagnostics, counts = diagnostic_items(buf, math.max(1, cursorLine - 3), math.min(lineCount, cursorLine + 3))
	s.current.diagnosticsNearCursor = diagnostics
	s.current.diagnosticCountsNearCursor = counts
	local syntax = syntax_context(buf)
	if syntax then
		s.current.syntaxAncestors = syntax.syntaxAncestors
		s.current.symbolAtCursor = syntax.symbolAtCursor
	end
	return s
end

function M.read_buffer(p)
	p = p or {}
	local buf = bufnr(p)
	local lineCount = vim.api.nvim_buf_line_count(buf)
	local startLine = p.startLine or 1
	local endLine = p.endLine or lineCount
	local lines = vim.api.nvim_buf_get_lines(buf, startLine - 1, endLine, false)
	return {
		buffer = buf,
		file = file_of(buf),
		startLine = startLine,
		endLine = endLine,
		lines = lines,
		lineCount = lineCount,
		modified = vim.bo[buf].modified,
	}
end

function M.replace_buffer_range(p)
	p = p or {}
	local buf = bufnr(p)
	local startLine = p.startLine
	local endLine = p.endLine
	local lines = p.lines or {}
	vim.api.nvim_buf_set_lines(buf, startLine - 1, endLine, false, lines)
	return {
		buffer = buf,
		file = file_of(buf),
		startLine = startLine,
		endLine = endLine,
		newLineCount = #lines,
		modified = vim.bo[buf].modified,
	}
end

function M.replace_selection(p)
	p = p or {}
	local buf = vim.api.nvim_get_current_buf()
	local sel = active_selection(buf)
	if not sel then
		error("No active visual selection")
	end
	local replacement = vim.split(p.text or "", "\\n", { plain = true })
	if sel.mode == "line" then
		vim.api.nvim_buf_set_lines(buf, sel.start.line - 1, sel["end"].line, false, replacement)
	else
		vim.api.nvim_buf_set_text(
			buf,
			sel.start.line - 1,
			math.max(sel.start.column - 1, 0),
			sel["end"].line - 1,
			sel["end"].column,
			replacement
		)
	end
	return {
		buffer = buf,
		file = file_of(buf),
		selection = sel,
		replacementLineCount = #replacement,
		modified = vim.bo[buf].modified,
	}
end

function M.apply_text_edits(p)
	p = p or {}
	local buf = bufnr(p)
	local edits = p.edits or {}
	table.sort(edits, function(a, b)
		if a.start.line ~= b.start.line then
			return a.start.line > b.start.line
		end
		return a.start.column > b.start.column
	end)
	for _, e in ipairs(edits) do
		local lines = vim.split(e.newText or "", "\\n", { plain = true })
		vim.api.nvim_buf_set_text(
			buf,
			e.start.line - 1,
			e.start.column - 1,
			e["end"].line - 1,
			e["end"].column - 1,
			lines
		)
	end
	return { buffer = buf, file = file_of(buf), editCount = #edits, modified = vim.bo[buf].modified }
end

function M.save_buffer(p)
	p = p or {}
	local buf = bufnr(p)
	vim.api.nvim_buf_call(buf, function()
		vim.cmd("write")
	end)
	return { buffer = buf, file = file_of(buf), modified = vim.bo[buf].modified }
end

function M.open_file(p)
	p = p or {}
	vim.cmd.edit(vim.fn.fnameescape(p.path))
	if p.line then
		vim.api.nvim_win_set_cursor(0, { p.line, math.max((p.column or 1) - 1, 0) })
	end
	local buf = vim.api.nvim_get_current_buf()
	local cur = vim.api.nvim_win_get_cursor(0)
	return { buffer = buf, file = file_of(buf), cursor = pos(cur[1], cur[2]) }
end

function M.get_diagnostics(p)
	p = p or {}
	local buf = bufnr(p)
	local diagnostics, counts = diagnostic_items(buf, p.startLine, p.endLine)
	return { buffer = buf, file = file_of(buf), diagnostics = diagnostics, counts = counts }
end

function M.rename_symbol(p)
	p = p or {}
	if p.line then
		vim.api.nvim_win_set_cursor(0, { p.line, math.max((p.column or 1) - 1, 0) })
	end
	local clients = vim.lsp.get_clients({ bufnr = 0, method = "textDocument/rename" })
	if #clients == 0 then
		error("No LSP client supports textDocument/rename")
	end
	local client = clients[1]
	local requestParams = vim.lsp.util.make_position_params(0, client.offset_encoding or "utf-16")
	requestParams.newName = p.newName
	local results = vim.lsp.buf_request_sync(0, "textDocument/rename", requestParams, 10000) or {}
	local response = results[client.id]
	if not response then
		for _, candidate in pairs(results) do
			response = candidate
			break
		end
	end
	if not response or response.err then
		error(response and vim.inspect(response.err) or "Rename request failed")
	end
	local edit = response.result
	if not edit then
		return { fileCount = 0, editCount = 0, workspaceEdit = nil }
	end
	vim.lsp.util.apply_workspace_edit(edit, client.offset_encoding or "utf-16")
	local fileCount, editCount = 0, 0
	if edit.changes then
		for _, edits in pairs(edit.changes) do
			fileCount = fileCount + 1
			editCount = editCount + #edits
		end
	end
	if edit.documentChanges then
		fileCount = #edit.documentChanges
		for _, change in ipairs(edit.documentChanges) do
			if change.edits then
				editCount = editCount + #change.edits
			end
		end
	end
	return { fileCount = fileCount, editCount = editCount, workspaceEdit = edit }
end

function M.list_code_actions(p)
	p = p or {}
	local client = vim.lsp.get_clients({ bufnr = 0 })[1]
	local enc = (client and client.offset_encoding) or "utf-16"
	local range
	if p.startLine then
		range = {
			start = { line = p.startLine - 1, character = (p.startColumn or 1) - 1 },
			["end"] = { line = (p.endLine or p.startLine) - 1, character = (p.endColumn or p.startColumn or 1) - 1 },
		}
	else
		local sel = active_selection(vim.api.nvim_get_current_buf())
		if sel then
			range = {
				start = { line = sel.start.line - 1, character = sel.start.column - 1 },
				["end"] = { line = sel["end"].line - 1, character = sel["end"].column - 1 },
			}
		else
			local cur = vim.api.nvim_win_get_cursor(0)
			range = {
				start = { line = cur[1] - 1, character = cur[2] },
				["end"] = { line = cur[1] - 1, character = cur[2] },
			}
		end
	end
	local requestParams = vim.lsp.util.make_range_params(0, enc)
	requestParams.range = range
	requestParams.context = { diagnostics = vim.diagnostic.get(0, { lnum = range.start.line }) }
	local results = vim.lsp.buf_request_sync(0, "textDocument/codeAction", requestParams, 10000) or {}
	local actions = {}
	for client_id, response in pairs(results) do
		for _, action in ipairs(response.result or {}) do
			table.insert(actions, { title = action.title, kind = action.kind, clientId = client_id, raw = action })
		end
	end
	return { actions = actions, range = range }
end

function M.apply_code_action(p)
	p = p or {}
	local action = p.action
	local clientId = p.clientId
	local fileCount, editCount = 0, 0
	local encoding = "utf-16"
	if clientId then
		local client = vim.lsp.get_client_by_id(clientId)
		if client and client.offset_encoding then
			encoding = client.offset_encoding
		end
	end
	if action.edit then
		vim.lsp.util.apply_workspace_edit(action.edit, encoding)
		if action.edit.changes then
			for _, edits in pairs(action.edit.changes) do
				fileCount = fileCount + 1
				editCount = editCount + #edits
			end
		end
		if action.edit.documentChanges then
			fileCount = #action.edit.documentChanges
			for _, change in ipairs(action.edit.documentChanges) do
				if change.edits then
					editCount = editCount + #change.edits
				end
			end
		end
	end
	if action.command then
		if type(action.command) == "string" then
			vim.lsp.buf.execute_command(action)
		else
			vim.lsp.buf.execute_command(action.command)
		end
	end
	return { fileCount = fileCount, editCount = editCount, title = action.title or action.command, kind = action.kind }
end

function M.format_buffer(p)
	p = p or {}
	local buf = bufnr(p)
	vim.lsp.buf.format({ bufnr = buf, timeout_ms = p.timeoutMs or 10000 })
	return { buffer = buf, file = file_of(buf), modified = vim.bo[buf].modified }
end

function M.organize_imports(p)
	p = p or {}
	local buf = bufnr(p)
	local lineCount = vim.api.nvim_buf_line_count(buf)
	local requestParams = {
		textDocument = { uri = vim.uri_from_bufnr(buf) },
		range = { start = { line = 0, character = 0 }, ["end"] = { line = lineCount, character = 0 } },
		context = { only = { "source.organizeImports" }, diagnostics = {} },
	}
	local results = vim.lsp.buf_request_sync(buf, "textDocument/codeAction", requestParams, 10000) or {}
	local count = 0
	for _, response in pairs(results) do
		for _, action in ipairs(response.result or {}) do
			count = count + 1
			if action.edit then
				vim.lsp.util.apply_workspace_edit(action.edit, "utf-16")
			end
			if action.command then
				if type(action.command) == "string" then
					vim.lsp.buf.execute_command(action)
				else
					vim.lsp.buf.execute_command(action.command)
				end
			end
		end
	end
	return { buffer = buf, file = file_of(buf), actionCount = count, modified = vim.bo[buf].modified }
end

function M.add_virtual_texts(p)
	p = p or {}
	local buf = bufnr(p)
	local nsName = p.namespace or "pi-neovim"
	local ns = vim.api.nvim_create_namespace(nsName)
	local marks = {}
	for _, item in ipairs(p.texts or {}) do
		local opts = { virt_text = { { item.text, item.hlGroup or "DiagnosticWarn" } } }
		local position = item.position or "eol"
		if position == "above" then
			opts.virt_lines = { { { item.text, item.hlGroup or "DiagnosticWarn" } } }
			opts.virt_text = nil
		else
			opts.virt_text_pos = position
		end
		local id = vim.api.nvim_buf_set_extmark(buf, ns, item.line - 1, math.max((item.column or 1) - 1, 0), opts)
		table.insert(marks, { id = id, line = item.line, text = item.text })
	end
	return { buffer = buf, file = file_of(buf), namespace = nsName, marks = marks }
end

function M.clear_virtual_texts(p)
	p = p or {}
	local buf = bufnr(p)
	local nsName = p.namespace or "pi-neovim"
	local ns = vim.api.nvim_create_namespace(nsName)
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	return { buffer = buf, file = file_of(buf), namespace = nsName }
end

return M
