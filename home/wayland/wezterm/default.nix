{config, ...}: {
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local config = require("config")
      config.colors = {
          foreground = "#${config.colors.foreground}",
          background = "#${config.colors.background}",

          cursor_bg = "#${config.colors.dark_fg}",
          cursor_fg = "#${config.colors.dark_fg}",
          cursor_border = "#${config.colors.dark_fg}",

          selection_fg = "#${config.colors.dark_fg}",
          selection_bg = "#${config.colors.blue}",

          scrollbar_thumb = "#${config.colors.black}",
          split = "#${config.colors.black}",

          ansi = {
            "#${config.colors.black}",
            "#${config.colors.red}",
            "#${config.colors.green}",
            "#${config.colors.yellow}",
            "#${config.colors.blue}",
            "#${config.colors.purple}",
            "#${config.colors.cyan}",
            "#${config.colors.white}",
          },
          brights = {
            "#${config.colors.bright-black}",
            "#${config.colors.bright-red}",
            "#${config.colors.bright-green}",
            "#${config.colors.bright-yellow}",
            "#${config.colors.bright-blue}",
            "#${config.colors.bright-purple}",
            "#${config.colors.bright-cyan}",
            "#${config.colors.bright-white}",
          },
      }
      return config
    '';
  };
  xdg.configFile."wezterm/config.lua".source = ./config.lua;
}
