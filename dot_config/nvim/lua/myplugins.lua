if true then
  -- rm -r ~/.config/nvim/pack
  return {
    {
      "debugloop/telescope-undo.nvim",
      function()
        require("telescope").load_extension("undo")
        vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>")
      end,
      requires = { "nvim-telescope/telescope.nvim" },
    },
  }
else
  -- mkdir -p ~/.config/nvim/pack/plugins/opt/; ln -sf ~/code/telescope-undo.nvim ~/.config/nvim/pack/plugins/opt/telescope-undo.nvim
  vim.cmd("packadd telescope-undo.nvim")
  require("telescope").load_extension("undo")
  vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>")
  return {}
end
