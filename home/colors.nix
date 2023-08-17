{ config, lib, ... }:

with lib;
let
  colorType = types.addCheck types.str (x: !isNull (builtins.match "[0-9a-fA-F]{6}" x));
  color = mkOption { type = colorType; };
  themeType = mkOption {
    type = types.submodule {
      options = {
        black = mkOption { type = colorType; };
        bright-black = mkOption { type = colorType; };
        red = mkOption { type = colorType; };
        bright-red = mkOption { type = colorType; };
        green = mkOption { type = colorType; };
        bright-green = mkOption { type = colorType; };
        yellow = mkOption { type = colorType; };
        bright-yellow = mkOption { type = colorType; };
        blue = mkOption { type = colorType; };
        bright-blue = mkOption { type = colorType; };
        purple = mkOption { type = colorType; };
        bright-purple = mkOption { type = colorType; };
        cyan = mkOption { type = colorType; };
        bright-cyan = mkOption { type = colorType; };
        white = mkOption { type = colorType; };
        bright-white = mkOption { type = colorType; };
        dark_bg = mkOption { type = colorType; };
        background = mkOption { type = colorType; };
        light_bg = mkOption { type = colorType; };
        foreground = mkOption { type = colorType; };
        dark_fg = mkOption { type = colorType; };
      };
    };
  };
in
{
  options = {
    themes = mkOption { type = types.attrsOf themeType; };
    colors = themeType;
  };
  config = rec {
    colors = themes.kanagawa;
    themes = {
      everforest =
        let
          bg_dim = "232a2e";
          bg0 = "2d353b";
          bg1 = "343f44";
          bg2 = "3d484d";
          bg3 = "475258";
          bg4 = "4f585e";
          bg5 = "56635f";
          bg_visual = "543a48";
          bg_red = "514045";
          bg_green = "425047";
          bg_blue = "3a515d";
          bg_yellow = "4d4c43";
          fg = "d3c6aa";
          red = "e67e80";
          orange = "e69875";
          yellow = "dbbc7f";
          green = "a7c080";
          aqua = "83c092";
          blue = "7fbbb3";
          purple = "d699b6";
          grey0 = "7a8478";
          grey1 = "859289";
          grey2 = "9da9a0";
          statusline1 = "a7c080";
          statusline2 = "d3c6aa";
          statusline3 = "e67e80";
        in
        {
          black = bg0;
          bright-black = bg2;
          red = red;
          bright-red = statusline3;
          green = green;
          bright-green = statusline1;
          yellow = yellow;
          bright-yellow = statusline2;
          blue = blue;
          bright-blue = blue;
          purple = purple;
          bright-purple = purple;
          cyan = aqua;
          bright-cyan = aqua;
          white = fg;
          bright-white = fg;
          dark_bg = bg_dim;
          background = bg0;
          light_bg = bg2;
          foreground = fg;
          dark_fg = grey2;
        };
      kanagawa =
        let
          fujiwhite = "dcd7ba"; # default foreground
          oldwhite = "c8c093"; # dark foreground (statuslines)
          sumiink0 = "16161d"; # dark background (statuslines and floating windows)
          sumiink1 = "1f1f28"; # default background
          sumiink2 = "2a2a37"; # lighter background (colorcolumn, folds)
          sumiink3 = "363646"; # lighter background (cursorline)
          sumiink4 = "54546d"; # darker foreground (line numbers, fold column, non-text characters), float borders
          waveblue1 = "223249"; # popup background, visual selection background
          waveblue2 = "2d4f67"; # popup selection background, search background
          wintergreen = "2b3328"; # diff add (background)
          winteryellow = "49443c"; # diff change (background)
          winterred = "43242b"; # diff deleted (background)
          winterblue = "252535"; # diff line (background)
          autumngreen = "76946a"; # git add
          autumnred = "c34043"; # git delete
          autumnyellow = "dca561"; # git change
          samuraired = "e82424"; # diagnostic error
          roninyellow = "ff9e3b"; # diagnostic warning
          waveaqua1 = "6a9589"; # diagnostic info
          dragonblue = "658594"; # diagnostic hint
          fujigray = "727169"; # comments
          springviolet1 = "938aa9"; # light foreground
          oniviolet = "957fb8"; # statements and keywords
          crystalblue = "7e9cd8"; # functions and titles
          springviolet2 = "9cabca"; # brackets and punctuation
          springblue = "7fb4ca"; # specials and builtin functions
          lightblue = "a3d4d5"; # not used
          waveaqua2 = "7aa89f"; # types
          springgreen = "98bb6c"; # strings
          boatyellow1 = "938056"; # not used
          boatyellow2 = "c0a36e"; # operators, regex
          carpyellow = "e6c384"; # identifiers
          sakurapink = "d27e99"; # numbers
          wavered = "e46876"; # standout specials 1 (builtin variables)
          peachred = "ff5d62"; # standout specials 2 (exception handling, return)
          surimiorange = "ffa066"; # constants, imports, booleans
        in
        {
          black = sumiink0;
          bright-black = fujigray;
          red = autumnred;
          bright-red = samuraired;
          green = autumngreen;
          bright-green = springgreen;
          yellow = boatyellow2;
          bright-yellow = carpyellow;
          blue = crystalblue;
          bright-blue = springblue;
          purple = oniviolet;
          bright-purple = springviolet1;
          cyan = waveaqua1;
          bright-cyan = waveaqua2;
          white = oldwhite;
          bright-white = fujiwhite;
          dark_bg = sumiink0;
          background = sumiink1;
          light_bg = sumiink3;
          foreground = fujiwhite;
          dark_fg = oldwhite;
        };
    };
  };
}
