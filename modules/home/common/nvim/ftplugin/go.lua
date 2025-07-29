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
  -- return immediately if we're not in a test file
  if vim.fn.expand("%:t"):sub(-#"_test.go", -1) ~= "_test.go" then
    return false, ""
  end
  -- see if we can find a specific test to run
  local node = vim.treesitter.get_node()
  while node do
    if node:type() == "function_declaration" or node:type() == "method_declaration" then
      local name = node:named_child(0)
      if name then
        return true, vim.treesitter.get_node_text(name, 0)
      end
      break
    end
    node = node:parent()
  end

  return true, ""
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
