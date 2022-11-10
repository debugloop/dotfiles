require("nvim-goc").setup({ verticalSplit = false })
vim.keymap.set("n", "<leader>tc", function()
  if GocCoverageOn == true then
    require("nvim-goc").ClearCoverage()
    GocCoverageOn = false
  else
    require("nvim-goc").Coverage()
    GocCoverageOn = true
  end
end, { desc = "test: show coverage" })
vim.keymap.set("n", "<leader>a", require("nvim-goc").Alternate, { desc = "goto or create test file" })
