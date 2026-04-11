{
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
      (import
        ./plugins.nix {inherit pkgs;})
    );
}
