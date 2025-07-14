local function root_dir(patterns)
  patterns = patterns or {}
  local matches = vim.fs.find(patterns, {
    upward = true,
  })
  if matches then
    return vim.fs.dirname(matches[1])
  end

  local default_patterns = { ".git/", "README.md", "flake.nix" }
  return vim.fs.dirname(vim.fs.find(default_patterns, {
    upward = true,
  })[1])
end

-- remove defaults
vim.keymap.del("n", "gO")
vim.keymap.del("n", "gra")
vim.keymap.del("n", "gri")
vim.keymap.del("n", "grn")
vim.keymap.del("n", "grr")

-- add my own
vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { desc = "lsp: rename symbol" })
vim.keymap.set("n", "<leader>?", vim.lsp.buf.code_action, { desc = "lsp: run code action" })
vim.keymap.set("n", "go", vim.lsp.buf.document_symbol, { desc = "lsp: show symbols" })
vim.keymap.set("n", "gO", vim.lsp.buf.workspace_symbol, { desc = "lsp: show workspacesymbols" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "lsp: show definition" })
vim.keymap.set("n", "gD", vim.lsp.buf.type_definition, { desc = "lsp: show type definition" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "lsp: show implementations" })
vim.keymap.set("n", "gr", function()
  vim.lsp.buf.references({ includeDeclaration = false })
end, { desc = "lsp: show references" })
vim.keymap.set("n", "gh", vim.lsp.buf.incoming_calls, { desc = "lsp: show callers" })
vim.keymap.set("n", "gH", vim.lsp.buf.outgoing_calls, { desc = "lsp: show callees" })
vim.keymap.set("n", "<leader>sd", vim.diagnostic.setqflist, { desc = "lsp: list diagnostics" })

vim.lsp.config("gopls", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  on_attach = function(_, _)
    -- modify some semantic tokens
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
  root_dir = root_dir({ "go.mod", "go.sum" }),
  single_file_support = true,
  settings = {
    gopls = {
      buildFlags = { "-tags=unit,integration,e2e" },
      directoryFilters = { "-.git" },
      gofumpt = true,
      codelenses = {
        test = true,
        vulncheck = true,
      },
      semanticTokens = true,
      staticcheck = true,
      vulncheck = "Imports",
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      completeUnimported = true,
      deepCompletion = true,
    },
  },
})

vim.lsp.config("templ", {
  cmd = { "templ", "lsp" },
  filetypes = { "templ" },
  root_dir = root_dir({ "go.mod", "go.sum" }),
})

vim.lsp.config("javascript", {
  init_options = {
    hostInfo = "neovim",
  },
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
  root_dir = root_dir(),
  single_file_support = true,
})

vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_dir = root_dir({ ".stylua.toml" }),
  single_file_support = true,
  log_level = vim.lsp.protocol.MessageType.Warning,
  settings = {
    Lua = {
      telemetry = { enable = false },
      diagnostics = {
        disable = { "missing-fields" },
      },
    },
  },
})

vim.lsp.config("nixd", {
  cmd = { "nixd" },
  filetypes = { "nix" },
  single_file_support = true,
  root_dir = root_dir(),
})

vim.lsp.config("typos-lsp", {
  cmd = { "typos-lsp" },
  root_dir = root_dir(),
  single_file_support = true,
  init_options = {
    diagnosticSeverity = "hint",
  },
})

vim.lsp.enable({ "gopls", "typos-lsp", "nixd", "templ", "javascript", "lua_ls" })
