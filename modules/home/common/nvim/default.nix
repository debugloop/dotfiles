{
  pkgs,
  config,
  ...
}: let
  nvimPlugins = import ./plugins.nix {inherit pkgs;};

  startPlugins = builtins.listToAttrs (
    map (name: {
      name = "nvim/site/pack/nixpkgs/start/${name}";
      value.source = pkgs.vimPlugins.${name};
    })
    nvimPlugins.startPluginNames
  );

  layersPlugin = {
    "nvim/site/pack/nixpkgs/start/${nvimPlugins.layersNvim.name}".source =
      nvimPlugins.layersNvim.src;
  };
in {
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
      # treesitter parsers (placed in site/ for automatic discovery)
      "nvim/site/parser".source = "${nvimPlugins.treesitterParsers}/parser";
    }
    // startPlugins
    // layersPlugin;
}
