require("telescope").setup({
  defaults = {
    dynamic_preview_title = true,
    mappings = {
      i = {
        ["<c-j>"] = require("telescope.actions").move_selection_next,
        ["<c-k>"] = require("telescope.actions").move_selection_previous,
        ["<esc>"] = require("telescope.actions").close,
      },
    },
  },
})
vim.keymap.set("n", "<leader>ft", require("telescope.builtin").builtin, { desc = "telescope pick telescope" })
vim.keymap.set("n", "<leader>/", require("telescope.builtin").live_grep, { desc = "telescope grep in project" })

-- lsp related pickers
vim.keymap.set("n", "gd", require("telescope.builtin").lsp_definitions, { desc = "lsp: goto definition" })
vim.keymap.set("n", "gr", require("telescope.builtin").lsp_references, { desc = "lsp: list references" })
vim.keymap.set("n", "gI", require("telescope.builtin").lsp_implementations, { desc = "lsp: list implementations" })
vim.keymap.set("n", "gO", require("telescope.builtin").lsp_document_symbols, { desc = "lsp: outline symbols" })
vim.keymap.set("n", "gC", require("telescope.builtin").lsp_incoming_calls, { desc = "lsp: list incoming calls" })

-- register noice with ourselves
require("telescope").load_extension("noice")
vim.keymap.set("n", "<leader>n", require("telescope").extensions.noice.noice, { desc = "open messages" })
