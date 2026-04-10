{pkgs, ...}: let
  nvimDir = ../modules/home/common/nvim;
  nvimPlugins = import "${nvimDir}/plugins.nix" {inherit pkgs;};

  allStartPlugins =
    map (name: pkgs.vimPlugins.${name}) nvimPlugins.startPluginNames
    ++ [nvimPlugins.layersNvim.src];

  configDir = pkgs.runCommand "nvim-config" {} ''
    mkdir -p $out/nvim
    cp -r ${nvimDir}/init.lua ${nvimDir}/lua ${nvimDir}/lsp \
          ${nvimDir}/ftplugin ${nvimDir}/after $out/nvim/
  '';

  wrappedNvim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
    plugins = map (p: {plugin = p;}) allStartPlugins;
    wrapRc = false;
    wrapperArgs = ["--set" "XDG_CONFIG_HOME" "${configDir}"];
  };
in
  pkgs.writeShellScriptBin "nvim" ''
    exec ${wrappedNvim}/bin/nvim \
      --cmd "set rtp+=${nvimPlugins.treesitterParsers}" \
      "$@"
  ''
