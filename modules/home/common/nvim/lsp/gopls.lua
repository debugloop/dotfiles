local util = require("lsp_util")

---@type vim.lsp.Config
return {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  on_attach = function(_, _)
    vim.o.foldexpr = "v:lua.vim.lsp.foldexpr()"

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
  root_dir = util.root_dir({ "go.mod", "go.sum" }),
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
      analyses = {
        ST1000 = false,
      },
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
    },
  },
}
