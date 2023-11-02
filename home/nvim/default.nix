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
    "nvim/after/queries/go/textobjects.scm".source = ./go-textobjects.scm;
    "nvim/snippets/go.snippets".source = ./go.snippets;
    "nvim/parser".source = "${pkgs.symlinkJoin { name = "treesitter-parsers"; paths = pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies; }}/parser";
  };

  xdg.dataFile = builtins.listToAttrs (lib.lists.forEach [
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
    "nvim-dap"
    "nvim-lint"
    "nvim-lspconfig"
    "nvim-snippy"
    "nvim-tree-lua"
    "nvim-treesitter"
    "nvim-treesitter-context"
    "nvim-treesitter-textobjects"
    "plenary-nvim"
    "telescope-fzf-native-nvim"
    "telescope-lsp-handlers-nvim"
    "telescope-nvim"
    "telescope-ui-select-nvim"
    "telescope-undo-nvim"
    "vim-illuminate"
    "vim-sleuth"
    "zk-nvim"
  ]
    (name:
      { name = "nvim/nixpkgs/${name}"; value = { source = builtins.getAttr "${name}" pkgs.vimPlugins; }; }
    ));
}

# TODO: implement time travel debugging for go
