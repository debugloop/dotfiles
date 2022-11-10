require("dap-go").setup()
vim.keymap.set("n", "<leader>td", require("dap-go").debug_test, { desc = "test: start debugging closest" })
