{ pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  xdg.configFile = {
    "nvim/init.lua".source = ./init.lua;
    "nvim/lua".source = ./lua;
    "nvim/after/queries/go/textobjects.scm".source = ./go-textobjects.scm;
    "nvim/snippets/go.snippets".source = ./go.snippets;
  };

  xdg.dataFile = {
    "nvim/nixpkgs/nvim-treesitter-parsers" = {
      source = "${pkgs.symlinkJoin { name = "treesitter-parsers"; paths = pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies; }}";
      #source = "${pkgs.symlinkJoin { name = "treesitter-parsers"; paths = (builtins.filter (x: ((builtins.parseDrvName x.name).name) != "lua-grammar") pkgs.vimPlugins.nvim-treesitter.allGrammars); }}";
    };
  }
  //
  (builtins.listToAttrs
    (lib.lists.forEach [
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
      "nvim-dap-go"
      "nvim-dap-virtual-text"
      "nvim-lint"
      "nvim-lspconfig"
      "nvim-snippy"
      "nvim-tree-lua"
      "nvim-treesitter"
      "nvim-treesitter-context"
      "nvim-treesitter-textobjects"
      "playground"
      "plenary-nvim"
      "telescope-fzf-native-nvim"
      "telescope-lsp-handlers-nvim"
      "telescope-nvim"
      "telescope-ui-select-nvim"
      "telescope-undo-nvim"
      "toggleterm-nvim"
      "vim-illuminate"
      "vim-sleuth"
      "zk-nvim"
    ]
      (name:
        { name = "nvim/nixpkgs/${name}"; value = { source = builtins.getAttr "${name}" pkgs.vimPlugins; }; }
      ))
  );
}
