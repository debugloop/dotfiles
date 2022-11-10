require("telescope").setup({
  defaults = {
    mappings = {
      i = {
        ["<C-j>"] = require("telescope.actions").move_selection_next,
        ["<C-k>"] = require("telescope.actions").move_selection_previous,
        ["<Esc>"] = require("telescope.actions").close,
      },
    },
  },
})
vim.keymap.set("n", "<leader>ft", require("telescope.builtin").builtin, { desc = "telescope pick telescope" })
vim.keymap.set(
  "n",
  "<leader>fr",
  require("telescope.builtin").lsp_references,
  { desc = "telescope pick lsp references" }
)
vim.keymap.set(
  "n",
  "<leader>fi",
  require("telescope.builtin").lsp_implementations,
  { desc = "telescope pick lsp implementations" }
)
vim.keymap.set(
  "n",
  "<leader>fs",
  require("telescope.builtin").lsp_document_symbols,
  { desc = "telescope pick lsp symbols" }
)
vim.keymap.set("n", "<leader>/", require("telescope.builtin").live_grep, { desc = "telescope grep in project" })

-- register noice with ourselves
require("telescope").load_extension("noice")
vim.keymap.set("n", "<leader>n", require("telescope").extensions.noice.noice, { desc = "telescope noice messages" })
