{pkgs}: [
  pkgs.vimPlugins.blink-cmp
  pkgs.vimPlugins.conform-nvim
  pkgs.vimPlugins.friendly-snippets
  pkgs.vimPlugins.kanagawa-nvim
  pkgs.vimPlugins.lazydev-nvim
  pkgs.vimPlugins.mini-nvim
  pkgs.vimPlugins.nvim-dap
  pkgs.vimPlugins.nvim-dap-view
  pkgs.vimPlugins.nvim-lint
  pkgs.vimPlugins.nvim-spider
  pkgs.vimPlugins.nvim-treesitter
  pkgs.vimPlugins.nvim-treesitter-textobjects
  pkgs.vimPlugins.snacks-nvim
  (pkgs.vimUtils.buildVimPlugin {
    pname = "layers-nvim";
    version = "git";
    src = pkgs.fetchFromGitHub {
      owner = "debugloop";
      repo = "layers.nvim";
      rev = "ebbb386d7aea84a04bf7eab0873975b2e9d695a5";
      sha256 = "0qam0a6h34hf8syw9yv936yilf6ib7cppkbk9wx74n030yna72k0";
    };
  })
]
