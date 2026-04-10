local M = {}

function M.root_dir(patterns)
  patterns = patterns or { ".git/", "README.md", "flake.nix" }
  return function(bufnr, on_dir)
    local path = vim.api.nvim_buf_get_name(bufnr)
    local matches = vim.fs.find(patterns, {
      upward = true,
      path = vim.fs.dirname(path),
    })
    on_dir(#matches > 0 and vim.fs.dirname(matches[1]) or nil)
  end
end

return M
