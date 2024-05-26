-- indent
vim.opt.tabstop = 8
vim.opt.expandtab = false

-- surrounding test name
function SurroundingTestName()
  local inTestfile = false
  if vim.fn.expand("%:t"):sub(-#"_test.go", -1) ~= "_test.go" then
    return inTestfile, ""
  else
    inTestfile = true
  end
  -- see if we can find a specific test to run
  local cursor = vim.api.nvim_win_get_cursor(0)
  local lsp_response, lsp_err = vim.lsp.buf_request_sync(
    0,
    "textDocument/documentSymbol",
    { textDocument = vim.lsp.util.make_text_document_params() },
    1000
  )
  if lsp_err ~= nil then
    return inTestfile, ""
  end

  for _, symbol in pairs(lsp_response[1].result) do
    if
      symbol["detail"] ~= nil
      and symbol.detail:sub(1, 4) == "func"
      and symbol.name:sub(1, 4) == "Test"
      and cursor[1] > symbol.range.start.line
      and cursor[1] < symbol.range["end"].line
    then
      return inTestfile, symbol.name
    end
  end

  return inTestfile, ""
end

vim.keymap.set("n", "gY", function()
  local inTestfile, testName = SurroundingTestName()
  if not inTestfile then
    return
  end

  local package = vim.fn.expand("%:h")
  if testName then
    vim.fn.setreg(
      "+",
      "ls "
        .. package
        .. "/* | entr -c gotest -v -tags unit,integration -test.run=^"
        .. testName
        .. "\\$ ./"
        .. vim.fn.expand("%:h")
        .. "/...",
      "V"
    )
  else
  end
end, { desc = "copy test command" })
