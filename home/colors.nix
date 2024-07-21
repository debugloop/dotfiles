{lib, ...}:
with lib; let
  colorType = types.addCheck types.str (x: !isNull (builtins.match "[0-9a-fA-F]{6}" x));
  themeType = mkOption {
    type = types.submodule {
      options = {
        black = mkOption {type = colorType;};
        bright-black = mkOption {type = colorType;};
        red = mkOption {type = colorType;};
        bright-red = mkOption {type = colorType;};
        green = mkOption {type = colorType;};
        bright-green = mkOption {type = colorType;};
        yellow = mkOption {type = colorType;};
        bright-yellow = mkOption {type = colorType;};
        blue = mkOption {type = colorType;};
        bright-blue = mkOption {type = colorType;};
        purple = mkOption {type = colorType;};
        bright-purple = mkOption {type = colorType;};
        cyan = mkOption {type = colorType;};
        bright-cyan = mkOption {type = colorType;};
        white = mkOption {type = colorType;};
        bright-white = mkOption {type = colorType;};
        dark_bg = mkOption {type = colorType;};
        background = mkOption {type = colorType;};
        light_bg = mkOption {type = colorType;};
        foreground = mkOption {type = colorType;};
        dark_fg = mkOption {type = colorType;};
      };
    };
  };
in {
  options = {
    themes = mkOption {type = types.attrsOf themeType;};
    colors = themeType;
  };
  config = rec {
    colors = themes.kanagawa;
    themes = {
      catppuccin = let
        rosewater = "f5e0dc"; #f5e0dc
        # flamingo = "f2cdcd"; #f2cdcd
        pink = "f5c2e7"; #f5c2e7
        mauve = "cba6f7"; #cba6f7
        red = "f38ba8"; #f38ba8
        # maroon = "eba0ac"; #eba0ac
        # peach = "fab387"; #fab387
        yellow = "f9e2af"; #f9e2af
        green = "a6e3a1"; #a6e3a1
        teal = "94e2d5"; #94e2d5
        sky = "89dceb"; #89dceb
        # sapphire = "74c7ec"; #74c7ec
        blue = "89b4fa"; #89b4fa
        lavender = "b4befe"; #b4befe
        text = "cdd6f4"; #cdd6f4
        # subtext1 = "bac2de"; #bac2de
        # subtext0 = "a6adc8"; #a6adc8
        # overlay2 = "9399b2"; #9399b2
        # overlay1 = "7f849c"; #7f849c
        # overlay0 = "6c7086"; #6c7086
        surface2 = "585b70"; #585b70
        # surface1 = "45475a"; #45475a
        surface0 = "313244"; #313244
        base = "1e1e2e"; #1e1e2e
        mantle = "181825"; #181825
        crust = "11111b"; #11111b
      in {
        black = crust;
        bright-black = surface2;
        red = red;
        bright-red = pink;
        green = green;
        bright-green = green;
        yellow = yellow;
        bright-yellow = rosewater;
        blue = blue;
        bright-blue = sky;
        purple = mauve;
        bright-purple = lavender;
        cyan = teal;
        bright-cyan = teal;
        white = text;
        bright-white = text;
        dark_bg = mantle;
        background = base;
        light_bg = surface0;
        foreground = text;
        dark_fg = rosewater;
      };
      kanagawa = let
        sumiInk0 = "16161d"; #16161d
        # sumiInk1 = "181820"; #181820
        # sumiInk2 = "1a1a22"; #1a1a22
        sumiInk3 = "1f1f28"; #1f1f28
        # sumiInk4 = "2a2a37"; #2a2a37
        sumiInk5 = "363646"; #363646
        # sumiInk6 = "54546d"; #54546d
        # waveBlue1 = "223249"; #223249
        # waveBlue2 = "2d4f67"; #2d4f67
        # winterGreen = "2b3328"; #2b3328
        # winterYellow = "49443c"; #49443c
        # winterRed = "43242b"; #43242b
        # winterBlue = "252535"; #252535
        autumnGreen = "76946a"; #76946a
        autumnRed = "c34043"; #c34043
        # autumnYellow = "dca561"; #dca561
        samuraiRed = "e82424"; #e82424
        # roninYellow = "ff9e3b"; #ff9e3b
        waveAqua1 = "6a9589"; #6a9589
        # dragonBlue = "658594"; #658594
        oldWhite = "c8c093"; #c8c093
        fujiWhite = "dcd7ba"; #dcd7ba
        fujiGray = "727169"; #727169
        oniViolet = "957fb8"; #957fb8
        # oniViolet2 = "b8b4d0"; #b8b4d0
        crystalBlue = "7e9cd8"; #7e9cd8
        springViolet1 = "938aa9"; #938aa9
        # springViolet2 = "9cabca"; #9cabca
        springBlue = "7fb4ca"; #7fb4ca
        # lightBlue = "a3d4d5"; #a3d4d5
        waveAqua2 = "7aa89f"; #7aa89f
        # waveAqua4 = "7aa880"; #7aa880
        # waveAqua5 = "6caf95"; #6caf95
        # waveAqua3 = "68ad99"; #68ad99
        springGreen = "98bb6c"; #98bb6c
        # boatYellow1 = "938056"; #938056
        boatYellow2 = "c0a36e"; #c0a36e
        carpYellow = "e6c384"; #e6c384
        # sakuraPink = "d27e99"; #d27e99
        # waveRed = "e46876"; #e46876
        # peachRed = "ff5d62"; #ff5d62
        # surimiOrange = "ffa066"; #ffa066
        # katanaGray = "717c7c"; #717c7c
      in {
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
