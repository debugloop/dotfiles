{pkgs, ...}: {
  startPluginNames = [
    "blink-cmp"
    "conform-nvim"
    "friendly-snippets"
    "kanagawa-nvim"
    "lazydev-nvim"
    "mini-nvim"
    "nvim-dap"
    "nvim-dap-view"
    "nvim-lint"
    "nvim-spider"
    "nvim-treesitter"
    "nvim-treesitter-textobjects"
    "snacks-nvim"
  ];

  layersNvim = {
    name = "layers-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "debugloop";
      repo = "layers.nvim";
      rev = "ebbb386d7aea84a04bf7eab0873975b2e9d695a5";
      sha256 = "0qam0a6h34hf8syw9yv936yilf6ib7cppkbk9wx74n030yna72k0";
    };
  };

  treesitterParsers = pkgs.symlinkJoin {
    name = "treesitter-parsers";
    paths = pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
  };
}
