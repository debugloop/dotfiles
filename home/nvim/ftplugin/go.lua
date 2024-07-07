-- indent
vim.opt.tabstop = 8
vim.opt.expandtab = false

-- lsp
vim.lsp.start({
  name = "gopls",
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_dir = vim.fs.dirname(vim.fs.find({ "go.mod", "go.sum", ".git/" }, { upward = true })[1]),
  single_file_support = true,
  capabilities = vim.lsp.protocol.make_client_capabilities(),
  settings = {
    gopls = {
      usePlaceholders = true,
      experimentalPostfixCompletions = true,
      staticcheck = true,
      codelenses = {
        gc_details = true,
        test = true,
      },
      analyses = {
        fieldalignment = false, -- useful, but better optimize for readability
        shadow = false, -- useful, but to spammy with `err`
        unusedvariable = true,
        useany = true,
      },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      buildFlags = { "-tags=unit,integration,e2e" },
    },
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_user_bindings_gopls", {}),
  callback = function(event)
    -- get gc details
    vim.keymap.set("n", "<leader>G", function()
      vim.lsp.buf_request_sync(0, "workspace/executeCommand", {
        command = "gopls.gc_details",
        arguments = { "file://" .. vim.api.nvim_buf_get_name(0) },
      }, 2000)
    end, { desc = "lsp: show GC details", buffer = event.buf })
    -- run current test
    vim.keymap.set("n", "<leader>t", function()
      local ok, inTestfile, testName = pcall(SurroundingTestName)
      if not ok or not inTestfile then
        return
      end
      vim.lsp.buf_request_sync(0, "workspace/executeCommand", {
        command = "gopls.run_tests",
        arguments = {
          {
            URI = vim.uri_from_bufnr(0),
            Tests = { testName },
          },
        },
      }, 10000)
      -- vim.lsp.buf.execute_command({
      --   command = "gopls.run_tests",
      -- })
    end, { desc = "lsp: show GC details", buffer = event.buf })
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
