{
  pkgs,
  lib,
  config,
  ...
}: {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    # package = pkgs.neovim;
  };

  home.sessionVariables = {
    MANPAGER = "nvim +Man!";
  };

  xdg.configFile = {
    "nvim/init.lua".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/modules/home/common/nvim/init.lua";
    "nvim/lua".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/modules/home/common/nvim/lua";
    "nvim/lsp".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/modules/home/common/nvim/lsp";
    "nvim/ftplugin".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/modules/home/common/nvim/ftplugin";
    "nvim/after".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/modules/home/common/nvim/after";
  };

  xdg.dataFile = let
    # All nixpkgs plugins, eagerly loaded via pack/nixpkgs/start/
    startPlugins = builtins.listToAttrs (
      lib.lists.forEach [
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
      ]
      (
        name: {
          name = "nvim/site/pack/nixpkgs/start/${name}";
          value = {
            source = builtins.getAttr "${name}" pkgs.vimPlugins;
          };
        }
      )
    );

    # layers.nvim: not in nixpkgs, fetched from GitHub
    layersPlugin = {
      "nvim/site/pack/nixpkgs/start/layers-nvim" = {
        source = pkgs.fetchFromGitHub {
          owner = "debugloop";
          repo = "layers.nvim";
          rev = "ebbb386d7aea84a04bf7eab0873975b2e9d695a5";
          sha256 = "0qam0a6h34hf8syw9yv936yilf6ib7cppkbk9wx74n030yna72k0";
        };
      };
    };

    treesitterParsers = pkgs.symlinkJoin {
      name = "treesitter-parsers";
      paths = pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
    };
  in
    {
      # treesitter parsers (placed in site/ for automatic discovery)
      "nvim/site/parser".source = "${treesitterParsers}/parser";
    }
    // startPlugins // layersPlugin;
}
