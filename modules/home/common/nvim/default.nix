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
    # "nvim/init.lua".source = ./init.lua;
    # "nvim/lua".source = ./lua;
    # "nvim/ftplugin".source = ./ftplugin;
    # "nvim/after".source = ./after;

    "nvim/init.lua".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/modules/home/common/nvim/init.lua";
    "nvim/lua".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/modules/home/common/nvim/lua";
    "nvim/ftplugin".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/modules/home/common/nvim/ftplugin";
    "nvim/after".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/modules/home/common/nvim/after";
  };

  xdg.dataFile = let
    vimPlugins = builtins.listToAttrs (
      lib.lists.forEach [
        "blink-cmp"
        "conform-nvim"
        "friendly-snippets"
        "kanagawa-nvim"
        "lazy-nvim"
        "lazydev-nvim"
        "noice-nvim"
        "nui-nvim"
        "nvim-dap"
        # "nvim-dap-view" # not in nixpkgs
        "nvim-lint"
      ]
      (
        name: {
          name = "nvim/nixpkgs/${name}";
          value = {
            source = builtins.getAttr "${name}" pkgs.vimPlugins;
          };
        }
      )
    );
    miniPlugins = builtins.listToAttrs (
      lib.lists.forEach [
        "mini-ai"
        "mini-bracketed"
        "mini-bufremove"
        "mini-clue"
        "mini-diff"
        "mini-extra"
        "mini-files"
        "mini-git"
        "mini-hipatterns"
        "mini-icons"
        "mini-indentscope"
        "mini-jump"
        "mini-operators"
        "mini-pairs"
        "mini-pick"
        "mini-sessions"
        "mini-splitjoin"
        "mini-statusline"
        "mini-surround"
        "mini-tabline"
        "mini-visits"
      ]
      (
        name: {
          name = "nvim/nixpkgs/${name}";
          value = {
            source = builtins.getAttr "mini-nvim" pkgs.vimPlugins;
          };
        }
      )
    );
    treesitterParsers = pkgs.symlinkJoin {
      name = "treesitter-parsers";
      paths = pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
      # paths = builtins.filter
      #   (x: (builtins.parseDrvName x.name).name != "vimplugin-treesitter-grammar-javascript")
      #   pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
    };
    treesitter = pkgs.fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter";
      rev = "main";
      sha256 = "sha256-usW9Z8+yilTLzs+8BzTyJad0L7CEoopXV/ExMuWlpoc=";
    };
  in
    {
      # treesitter main parsers:
      "nvim/site/queries" = {
        source = "${treesitter}/runtime/queries";
      };
      "nvim/site/parser".source = "${treesitterParsers}/parser";

      "nvim/nixpkgs/nvim-treesitter-textobjects" = {
        source = pkgs.fetchFromGitHub {
          owner = "nvim-treesitter";
          repo = "nvim-treesitter-textobjects";
          rev = "main";
          sha256 = "sha256-w2dzc5oWyEoPUgbqaAuNKCeFeh81rYJPOCPVRnFC724=";
        };
      };
      "nvim/nixpkgs/nvim-treesitter" = {
        source = treesitter;
      };
    }
    // vimPlugins // miniPlugins;
}
