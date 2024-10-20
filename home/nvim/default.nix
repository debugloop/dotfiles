{
  pkgs,
  lib,
  inputs,
  ...
}: {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    # package = pkgs.neovim-nightly;
  };

  xdg.configFile = let
    treesitterParsers = pkgs.symlinkJoin {
      name = "treesitter-parsers";
      paths = pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
      # paths = builtins.filter
      #   (x: (builtins.parseDrvName x.name).name != "vimplugin-treesitter-grammar-javascript")
      #   pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
    };
  in {
    "nvim/init.lua".source = ./init.lua;
    "nvim/lua".source = ./lua;
    "nvim/ftplugin".source = ./ftplugin;
    "nvim/parser".source = "${treesitterParsers}/parser";
    "nvim/after/queries/go/textobjects.scm".source = ./go-textobjects.scm;
    "nvim/after/queries/gotmpl/injections.scm".source = ./gotmpl-injections.scm;
  };

  xdg.dataFile = let
    vimPlugins = builtins.listToAttrs (
      lib.lists.forEach [
        "conform-nvim"
        "diffview-nvim"
        "friendly-snippets"
        "kanagawa-nvim"
        "lazy-nvim"
        "lazydev-nvim"
        "noice-nvim"
        "nui-nvim"
        "nvim-bqf"
        "nvim-dap"
        "nvim-lint"
        "nvim-pqf"
        "nvim-tree-lua"
        "nvim-treesitter"
        "nvim-treesitter-context"
        "nvim-treesitter-textobjects"
        "render-markdown-nvim"
        "zk-nvim"
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
    miniPlugin = builtins.getAttr "mini-nvim" pkgs.vimPlugins;
    miniPlugins = builtins.listToAttrs (
      lib.lists.forEach [
        "mini-ai"
        "mini-bracketed"
        "mini-bufremove"
        "mini-clue"
        "mini-completion"
        "mini-diff"
        "mini-extra"
        "mini-files"
        "mini-fuzzy"
        "mini-git"
        "mini-hipatterns"
        "mini-icons"
        "mini-indentscope"
        "mini-jump"
        "mini-operators"
        "mini-pairs"
        "mini-pick"
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
            source = miniPlugin;
          };
        }
      )
    );
  in
    {
      "nvim/nixpkgs/blink-cmp" = {
        source = inputs.nvim-blink-cmp.packages.${pkgs.system}.default;
      };
      "nvim/nixpkgs/fzf" = {
        source = "${pkgs.fzf}/share/vim-plugins/fzf";
      };
      "nvim/nixpkgs/nvim-impairative" = {
        source = pkgs.fetchFromGitHub {
          owner = "idanarye";
          repo = "nvim-impairative";
          rev = "v0.5.0";
          sha256 = "sha256-bXEABjb3HvVcQmVbDdDB5CSMp1rd+6AIFihOYnO1slg=";
        };
      };
    }
    // vimPlugins
    // miniPlugins;
}
