local M = {}

function M.root_dir(patterns)
  patterns = patterns or { ".git/", "README.md", "flake.nix" }
  local matches = vim.fs.find(patterns, {
    upward = true,
  })
  if matches then
    return vim.fs.dirname(matches[1])
  end
  return "~"
end

return M
