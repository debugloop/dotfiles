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
vim.lsp.config("gopls", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  on_attach = function(client, _)
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

vim.lsp.enable({ "gopls", "nixd", "templ", "javascript", "lua_ls" })

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("on_lsp_attach", {}),
  callback = function(event)
    -- commands
    vim.api.nvim_buf_create_user_command(event.buf, "LspRestart", function(_)
      vim.lsp.stop_client(vim.lsp.get_clients(), true)
      vim.cmd("edit!")
    end, { desc = "Restart all active LSP clients" })
  end,
})
