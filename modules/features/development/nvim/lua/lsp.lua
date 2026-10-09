-- remove defaults
vim.keymap.del("n", "gO")
vim.keymap.del("n", "gra")
vim.keymap.del("n", "gri")
vim.keymap.del("n", "grx")
vim.keymap.del("n", "grn")
vim.keymap.del("n", "grr")
vim.keymap.del("n", "grt")

vim.lsp.enable(vim.tbl_map(function(f)
  return (f:gsub("%.lua$", ""))
end, vim.fn.readdir(vim.fn.stdpath("config") .. "/lsp")))

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local buf = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end
    local map = function(mode, lhs, rhs, desc, method)
      if method and not client:supports_method(method, buf) then
        return
      end
      vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
    end

    map("n", "]]", function()
      Snacks.words.jump(vim.v.count1, true)
    end, "jump to next reference", "textDocument/documentHighlight")
    map("n", "[[", function()
      Snacks.words.jump(-vim.v.count1, true)
    end, "jump to prev reference", "textDocument/documentHighlight")
    map("n", "<leader>oh", function()
      Snacks.toggle.inlay_hints():toggle()
    end, "toggle inlay hints", "textDocument/inlayHint")
    map("n", "<leader>oI", function()
      Snacks.toggle.words():toggle()
    end, "toggle illumination", "textDocument/documentHighlight")
    map("n", "go", function()
      Snacks.picker.lsp_symbols({ layout = "bqflike" })
    end, "lsp: show symbols", "textDocument/documentSymbol")
    map("n", "gO", function()
      Snacks.picker.lsp_workspace_symbols({ layout = "bqflike" })
    end, "lsp: show all symbols", "workspace/symbol")
    map("n", "gd", function()
      Snacks.picker.lsp_definitions({ layout = "bqflike" })
    end, "lsp: show definition", "textDocument/definition")
    if vim.bo[buf].filetype == "nix" then
      map("n", "gD", function()
        local name = vim.fn.expand("<cword>")
        local root = vim.fs.root(buf, "flake.nix") or vim.fn.getcwd()
        Snacks.picker.grep({
          auto_confirm = true,
          cwd = root,
          glob = "*.nix",
          layout = "bqflike",
          live = false,
          search = "flake\\.modules\\.(nixos|homeManager)\\." .. name .. "\\s*=",
          title = "Nix module definition: " .. name,
        })
      end, "lsp: show type definition / Nix module definition")
    else
      map("n", "gD", function()
        Snacks.picker.lsp_type_definitions({ layout = "bqflike" })
      end, "lsp: show type definition / Nix module definition", "textDocument/typeDefinition")
    end
    map("n", "gi", function()
      Snacks.picker.lsp_implementations({ layout = "bqflike" })
    end, "lsp: show implementations", "textDocument/implementation")
    map("n", "gr", function()
      Snacks.picker.lsp_references({ layout = "bqflike" })
    end, "lsp: show refs", "textDocument/references")
    map("n", "gh", function()
      Snacks.picker.lsp_incoming_calls({ layout = "bqflike" })
    end, "lsp: show incoming", "textDocument/prepareCallHierarchy")
    map("n", "gH", function()
      Snacks.picker.lsp_outgoing_calls({ layout = "bqflike" })
    end, "lsp: show outgoing", "textDocument/prepareCallHierarchy")

    map("n", "<leader>r", vim.lsp.buf.rename, "lsp: rename symbol")
    map({ "n", "x" }, "<leader>?", function()
      local line = vim.api.nvim_win_get_cursor(0)[1]
      for _, lens in pairs(vim.lsp.codelens.get({ bufnr = buf })) do
        if lens.lens.range.start.line == (line - 1) and lens.lens.command and lens.lens.command.command ~= "" then
          vim.lsp.codelens.run()
          return
        end
      end
      vim.lsp.buf.code_action()
    end, "lsp: run codelens or code action")
    map("n", "<cr>", vim.lsp.buf.hover, "lsp: hover")

    vim.lsp.codelens.enable(true, { bufnr = buf })
  end,
})

vim.api.nvim_create_autocmd("LspProgress", {
  ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
  callback = function(ev)
    local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
    vim.notify(vim.lsp.status(), vim.log.levels.INFO, {
      id = "lsp_progress",
      title = "LSP Progress",
      opts = function(notif)
        notif.icon = ev.data.params.value.kind == "end" and " "
          or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
      end,
    })
  end,
})
