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
    "nvim/snippets/go.snippets".source = ./go.snippets;
    #"nvim/parser".source = "${pkgs.symlinkJoin { name = "treesitter-parsers"; paths = pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies; }}/parser";
    "nvim/parser".source = "${pkgs.symlinkJoin { name = "treesitter-parsers"; paths = builtins.filter (x: ((builtins.parseDrvName x.name).name) != "vimplugin-treesitter-grammar-javascript") pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies; }}/parser";
    
  };

  xdg.dataFile = builtins.listToAttrs (
    [{ name = "nvim/nixpkgs/fzf"; value = { source = "${pkgs.fzf}/share/vim-plugins/fzf"; }; }] ++
    lib.lists.forEach [
      "conform-nvim"
      "cmp-nvim-lsp"
      "cmp-snippy"
      "diffview-nvim"
      "flash-nvim"
      "gitlinker-nvim"
      "gitsigns-nvim"
      "heirline-nvim"
      "kanagawa-nvim"
      "lazy-nvim"
      "mini-nvim"
      "noice-nvim"
      "nui-nvim"
      "nvim-autopairs"
      "nvim-cmp"
      "nvim-bqf"
      "nvim-dap"
      "nvim-lint"
      "nvim-lspconfig"
      "nvim-snippy"
      "nvim-tree-lua"
      "nvim-treesitter"
      "nvim-treesitter-context"
      "nvim-treesitter-refactor"
      "nvim-treesitter-textobjects"
      "plenary-nvim"
      "telescope-nvim"
      "telescope-undo-nvim"
    ]
      (name:
        { name = "nvim/nixpkgs/${name}"; value = { source = builtins.getAttr "${name}" pkgs.vimPlugins; }; }
      )
  );


}
