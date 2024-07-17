-- indent
vim.opt.tabstop = 8
vim.opt.expandtab = false

-- lsp
vim.lsp.start({
  name = "gopls",
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  on_attach = function(client, bufnr)
    -- explicitly enable and modify some semantic tokens
    if not client.server_capabilities.semanticTokensProvider then
      local semantic = client.config.capabilities.textDocument.semanticTokens
      if semantic == nil then
        return
      end
      client.server_capabilities.semanticTokensProvider = {
        full = true,
        legend = {
          tokenTypes = semantic.tokenTypes,
          tokenModifiers = semantic.tokenModifiers,
        },
        range = true,
      }
    end
    vim.api.nvim_create_autocmd("LspTokenUpdate", {
      callback = function(args)
        local token = args.data.token
        if token.type == "keyword" and not token.modifiers.readonly then
          local keyword =
            vim.api.nvim_buf_get_text(args.buf, token.line, token.start_col, token.line, token.end_col, {})[1]
          if keyword == "return" or keyword == "package" or keyword == "import" or keyword == "go" then
            vim.lsp.semantic_tokens.highlight_token(token, args.buf, args.data.client_id, "@keyword.return")
          end
        end
      end,
    })
  end,
  root_dir = vim.fs.dirname(vim.fs.find({ "go.mod", "go.sum", ".git/" }, { upward = true })[1]),
  single_file_support = true,
  capabilities = vim.lsp.protocol.make_client_capabilities(),
  settings = {
    gopls = {
      buildFlags = { "-tags=unit,integration,e2e" },
      gofumpt = true,
      codelenses = {
        gc_details = true,
        generate = true,
        regenerate_cgo = true,
        run_govulncheck = true,
        test = true,
        tidy = true,
        upgrade_dependency = true,
        vendor = true,
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
      analyses = {
        fieldalignment = false, -- useful, but better optimize for readability
        shadow = false, -- useful, but to spammy with `err`
        nilness = true,
        unusedparams = true,
        unusedwrite = true,
        useany = true,
      },
      usePlaceholders = true,
      completeUnimported = true,
      staticcheck = true,
      directoryFilters = { "-.git" },
      semanticTokens = true,
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
