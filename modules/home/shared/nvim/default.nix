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
    # package = pkgs.neovim;
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
    # "nvim/init.lua".source = ./init.lua;
    # "nvim/lua".source = ./lua;
    # "nvim/ftplugin".source = ./ftplugin;
    # "nvim/after".source = ./after;

    "nvim/init.lua".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/modules/home/shared/nvim/init.lua";
    "nvim/lua".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/modules/home/shared/nvim/lua";
    "nvim/ftplugin".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/modules/home/shared/nvim/ftplugin";
    "nvim/after".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/modules/home/shared/nvim/after";

    "nvim/parser".source = "${treesitterParsers}/parser"; # treesitter master only
  };

  xdg.dataFile = let
    vimPlugins = builtins.listToAttrs (
      lib.lists.forEach [
        "blink-cmp"
        "conform-nvim"
        "diffview-nvim"
        "friendly-snippets"
        "kanagawa-nvim"
        "lazy-nvim"
        "lazydev-nvim"
        "noice-nvim"
        "nui-nvim"
        "nvim-dap"
        # "nvim-dap-view" # not in nixpkgs
        "nvim-lint"
        "nvim-treesitter" # uses master
        "nvim-treesitter-context"
        "nvim-treesitter-textobjects" # uses master
        "quicker-nvim"
        "snacks-nvim"
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
  in
    {
      "nvim/nixpkgs/fzf" = {
        source = "${pkgs.fzf}/share/vim-plugins/fzf";
      };

      # treesitter main parsers:
      # "nvim/site/queries" = {
      #   source = "${pkgs.vimPlugins.nvim-treesitter.withAllGrammars}/queries";
      # };
      # "nvim/site/parser".source = "${treesitterParsers}/parser";

      # for switching to treesitter main:
      # "nvim/nixpkgs/nvim-treesitter-textobjects" = {
      #   source = pkgs.fetchFromGitHub {
      #     owner = "nvim-treesitter";
      #     repo = "nvim-treesitter-textobjects";
      #     rev = "main";
      #     sha256 = "sha256-sJdKVaGNXW4HEi6NXEqUhelr8T7/M216m7bPKHAd1do=";
      #   };
      # };
      # "nvim/nixpkgs/nvim-treesitter" = {
      #   source = pkgs.fetchFromGitHub {
      #     owner = "nvim-treesitter";
      #     repo = "nvim-treesitter";
      #     rev = "main";
      #     sha256 = "sha256-m3ShsTug4wSee89K+GaTKodC1cWsskR35y9SjDtVRgU=";
      #   };
      # };
    }
    // vimPlugins // miniPlugins;
}
