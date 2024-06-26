{ pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    # package = pkgs.neovim-nightly;
  };

  xdg.configFile = {
    "nvim/init.lua".source = ./init.lua;
    "nvim/lua".source = ./lua;
    "nvim/ftplugin".source = ./ftplugin;
    "nvim/after/queries/go/textobjects.scm".source = ./go-textobjects.scm;
    "nvim/after/queries/gotmpl/injections.scm".source = ./gotmpl-injections.scm;
    "nvim/parser".source = "${pkgs.symlinkJoin { name = "treesitter-parsers"; paths = pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies; }}/parser";
    # "nvim/parser".source = "${pkgs.symlinkJoin { name = "treesitter-parsers"; paths = builtins.filter (x: ((builtins.parseDrvName x.name).name) != "vimplugin-treesitter-grammar-javascript") pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies; }}/parser";

  };

  xdg.dataFile = {
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
  } // builtins.listToAttrs (
    lib.lists.forEach [
      "conform-nvim"
      "cmp-nvim-lsp"
      "diffview-nvim"
      "heirline-nvim"
      "kanagawa-nvim"
      "lazy-nvim"
      "lazydev-nvim"
      "mini-nvim"
      "noice-nvim"
      "nui-nvim"
      "nvim-cmp"
      "nvim-bqf"
      "nvim-dap"
      "nvim-lint"
      "nvim-lspconfig"
      "nvim-notify"
      "nvim-pqf"
      "nvim-tree-lua"
      "nvim-treesitter"
      "nvim-treesitter-context"
      "nvim-treesitter-refactor"
      "nvim-treesitter-textobjects"
    ]
      (name:
        { name = "nvim/nixpkgs/${name}"; value = { source = builtins.getAttr "${name}" pkgs.vimPlugins; }; }
      )
  );


}
