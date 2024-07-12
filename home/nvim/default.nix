{ pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    # package = pkgs.neovim-nightly;
  };

  xdg.configFile =
    let
      treesitterParsers = pkgs.symlinkJoin {
        name = "treesitter-parsers";
        paths = pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
        # paths = builtins.filter
        #   (x: (builtins.parseDrvName x.name).name != "vimplugin-treesitter-grammar-javascript")
        #   pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
      };
    in
    {
      "nvim/init.lua".source = ./init.lua;
      "nvim/lua".source = ./lua;
      "nvim/ftplugin".source = ./ftplugin;
      "nvim/after/queries/go/textobjects.scm".source = ./go-textobjects.scm;
      "nvim/after/queries/gotmpl/injections.scm".source = ./gotmpl-injections.scm;
      "nvim/parser".source = "${treesitterParsers}/parser";
    };

  xdg.dataFile =
    let
      vimPlugins = builtins.listToAttrs (
        lib.lists.forEach [
          "conform-nvim"
          "cmp-nvim-lsp"
          "diffview-nvim"
          "kanagawa-nvim"
          "lazy-nvim"
          "lazydev-nvim"
          "noice-nvim"
          "nui-nvim"
          "nvim-cmp"
          "nvim-bqf"
          "nvim-dap"
          "nvim-lint"
          "nvim-pqf"
          "nvim-tree-lua"
          "nvim-treesitter"
          "nvim-treesitter-context"
          "nvim-treesitter-textobjects"
        ]
          (name:
            {
              name = "nvim/nixpkgs/${name}";
              value = {
                source = builtins.getAttr "${name}" pkgs.vimPlugins;
              };
            }
          )
      );
      # miniPlugin = builtins.getAttr "mini-nvim" pkgs.vimPlugins;
      miniPlugin = pkgs.fetchFromGitHub {
        owner = "echasnovski";
        repo = "mini.nvim";
        rev = "6c873ff81c318119923a424e3aea39000d3a10cf";
        sha256 = "sha256-XlSGXaYinJwMKOWdFz+Fyoi9L2bpWZupkr9W8LM6V7c=";
      };
      miniPlugins = builtins.listToAttrs (
        lib.lists.forEach [
          "mini-ai"
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
          "mini-splitjoin"
          "mini-statusline"
          "mini-surround"
          "mini-tabline"
          "mini-visits"
        ]
          (name:
            {
              name = "nvim/nixpkgs/${name}";
              value = {
                source = miniPlugin;
              };
            }
          )
      );
    in
    {
      "nvim/nixpkgs/fzf" = {
        source = "${pkgs.fzf}/share/vim-plugins/fzf";
      };
      "nvim/nixpkgs/nvim-impairative" = {
        source = pkgs.fetchFromGitHub {
          owner = "idanarye";
          repo = "nvim-impairative";
          rev = "v0.2.0";
          sha256 = "sha256-bXEABjb3HvVcQmVbDdDB5CSMp1rd+6AIFihOYnO1slg=";
        };
      };
    }
    // vimPlugins // miniPlugins;


}
