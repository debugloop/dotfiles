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
          bg_dim = "232a2e"; #232a2e
          bg0 = "2d353b"; #2d353b
          bg1 = "343f44"; #343f44
          bg2 = "3d484d"; #3d484d
          bg3 = "475258"; #475258
          bg4 = "4f585e"; #4f585e
          bg5 = "56635f"; #56635f
          bg_visual = "543a48"; #543a48
          bg_red = "514045"; #514045
          bg_green = "425047"; #425047
          bg_blue = "3a515d"; #3a515d
          bg_yellow = "4d4c43"; #4d4c43
          fg = "d3c6aa"; #d3c6aa
          red = "e67e80"; #e67e80
          orange = "e69875"; #e69875
          yellow = "dbbc7f"; #dbbc7f
          green = "a7c080"; #a7c080
          aqua = "83c092"; #83c092
          blue = "7fbbb3"; #7fbbb3
          purple = "d699b6"; #d699b6
          grey0 = "7a8478"; #7a8478
          grey1 = "859289"; #859289
          grey2 = "9da9a0"; #9da9a0
          statusline1 = "a7c080"; #a7c080
          statusline2 = "d3c6aa"; #d3c6aa
          statusline3 = "e67e80"; #e67e80
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
          sumiInk0 = "16161d"; #16161d
          sumiInk1 = "181820"; #181820
          sumiInk2 = "1a1a22"; #1a1a22
          sumiInk3 = "1f1f28"; #1f1f28
          sumiInk4 = "2a2a37"; #2a2a37
          sumiInk5 = "363646"; #363646
          sumiInk6 = "54546d"; #54546d
          waveBlue1 = "223249"; #223249
          waveBlue2 = "2d4f67"; #2d4f67
          winterGreen = "2b3328"; #2b3328
          winterYellow = "49443c"; #49443c
          winterRed = "43242b"; #43242b
          winterBlue = "252535"; #252535
          autumnGreen = "76946a"; #76946a
          autumnRed = "c34043"; #c34043
          autumnYellow = "dca561"; #dca561
          samuraiRed = "e82424"; #e82424
          roninYellow = "ff9e3b"; #ff9e3b
          waveAqua1 = "6a9589"; #6a9589
          dragonBlue = "658594"; #658594
          oldWhite = "c8c093"; #c8c093
          fujiWhite = "dcd7ba"; #dcd7ba
          fujiGray = "727169"; #727169
          oniViolet = "957fb8"; #957fb8
          oniViolet2 = "b8b4d0"; #b8b4d0
          crystalBlue = "7e9cd8"; #7e9cd8
          springViolet1 = "938aa9"; #938aa9
          springViolet2 = "9cabca"; #9cabca
          springBlue = "7fb4ca"; #7fb4ca
          lightBlue = "a3d4d5"; #a3d4d5
          waveAqua2 = "7aa89f"; #7aa89f
          waveAqua4  = "7aa880"; #7aa880
          waveAqua5  = "6caf95"; #6caf95
          waveAqua3  = "68ad99"; #68ad99
          springGreen = "98bb6c"; #98bb6c
          boatYellow1 = "938056"; #938056
          boatYellow2 = "c0a36e"; #c0a36e
          carpYellow = "e6c384"; #e6c384
          sakuraPink = "d27e99"; #d27e99
          waveRed = "e46876"; #e46876
          peachRed = "ff5d62"; #ff5d62
          surimiOrange = "ffa066"; #ffa066
          katanaGray = "717c7c"; #717c7c
        in
        {
          black = sumiInk0;
          bright-black = fujiGray;
          red = autumnRed;
          bright-red = samuraiRed;
          green = autumnGreen;
          bright-green = springGreen;
          yellow = boatYellow2;
          bright-yellow = carpYellow;
          blue = crystalBlue;
          bright-blue = springBlue;
          purple = oniViolet;
          bright-purple = springViolet1;
          cyan = waveAqua1;
          bright-cyan = waveAqua2;
          white = oldWhite;
          bright-white = fujiWhite;
          dark_bg = sumiInk0;
          background = sumiInk3;
          light_bg = sumiInk5;
          foreground = fujiWhite;
          dark_fg = oldWhite;
        };
    };
  };
}
