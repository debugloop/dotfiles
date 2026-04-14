_: {
  flake.modules.nixos.nvim = _: {
    environment.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  flake.modules.homeManager.nvim = {
    pkgs,
    config,
    lib,
    ...
  }: {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
      # new defaults as of 26.05; set explicitly to silence warnings
      withRuby = false;
      withPython3 = false;
    };

    home.sessionVariables = {
      MANPAGER = "nvim +Man!";
    };

    xdg.configFile = {
      "nvim/init.lua".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/modules/universal/nvim/init.lua";
      "nvim/lua".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/modules/universal/nvim/lua";
      "nvim/lsp".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/modules/universal/nvim/lsp";
      "nvim/ftplugin".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/modules/universal/nvim/ftplugin";
      "nvim/after".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/modules/universal/nvim/after";
    };

    xdg.dataFile =
      {
        "nvim/site/parser".source = "${pkgs.symlinkJoin {
          name = "treesitter-parsers";
          paths =
            pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
        }}/parser";
        "nvim/site/queries".source = "${pkgs.vimPlugins.nvim-treesitter.withAllGrammars}/runtime/queries";
      }
      // builtins.listToAttrs (
        map (plug: {
          name = "nvim/site/pack/nixpkgs/start/${lib.getName plug}";
          value.source = plug;
        })
        (import ./_plugins.nix {inherit pkgs;})
      );
  };
}
