{pkgs, ...}: let
  inherit (pkgs) lib;
  nvimDir = ../modules/home/common/nvim;
  nvimPlugins = import "${nvimDir}/plugins.nix" {inherit pkgs;};

  treesitterParsers = pkgs.symlinkJoin {
    name = "treesitter-parsers";
    paths = pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
  };

  configDir = pkgs.runCommand "nvim-config" {} ''
    mkdir -p $out/nvim
    cp -r ${nvimDir}/init.lua ${nvimDir}/lua ${nvimDir}/lsp \
          ${nvimDir}/ftplugin ${nvimDir}/after $out/nvim/
  '';

  wrappedNvim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
    wrapRc = false;
  };

  pluginPaths = lib.concatMapStringsSep " " (p: "${p}") nvimPlugins;
in
  pkgs.writeShellScriptBin "nvim" ''
    tmpdir=$(mktemp -d -t nvim-XXXXXX)
    cp -r ${configDir}/nvim "$tmpdir/"
    chmod -R u+w "$tmpdir/nvim"
    mkdir -p "$tmpdir/pack/nixpkgs/start"
    for p in ${pluginPaths}; do
      ln -s "$p" "$tmpdir/pack/nixpkgs/start/$(basename "$p")"
    done
    XDG_CONFIG_HOME="$tmpdir" ${wrappedNvim}/bin/nvim \
      --cmd "set packpath^=$tmpdir" \
      --cmd "set rtp+=${treesitterParsers}/parser" \
      "$@"
    exit_code=$?
    rm -rf "$tmpdir"
    exit $exit_code
  ''
