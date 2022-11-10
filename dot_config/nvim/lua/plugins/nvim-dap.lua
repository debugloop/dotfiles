vim.keymap.set("n", "<leader>b", require("dap").toggle_breakpoint, { desc = "debug: toggle breakpoint" })
vim.keymap.set("n", "<leader>B", function()
  require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "debug: set conditional breakpoint" })
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("on_dap_repl", {}),
  pattern = "dap-repl",
  callback = function()
    vim.cmd("startinsert")
  end,
})
