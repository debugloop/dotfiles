-- indent
vim.opt.tabstop = 8
vim.opt.expandtab = false

-- lsp
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_user_bindings_gopls", {}),
  callback = function(event)
    -- run current test
    vim.keymap.set("n", "<leader>t", function()
      local ok, inTestfile, testName = pcall(SurroundingTestName)
      if not ok or not inTestfile then
        return
      end
      local result = vim.lsp.buf_request_sync(0, "workspace/executeCommand", {
        command = "gopls.run_tests",
        arguments = {
          {
            URI = vim.uri_from_bufnr(0),
            Tests = { testName },
          },
        },
      }, 10000)
      if not result or result[1].error then
        vim.notify("Test failed", vim.log.levels.ERROR)
      else
        vim.notify("Test ok", vim.log.levels.INFO)
      end
    end, { desc = "lsp: run test at cursor", buffer = event.buf })
  end,
})

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
  if lsp_err ~= nil or lsp_response == nil then
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
