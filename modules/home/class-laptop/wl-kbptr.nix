{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    wl-kbptr
  ];

  xdg = {
    configFile."wl-kbptr/config".text = ''
      [general]
      modes=floating,click

      [mode_floating]
      source=detect
      label_color=#${config.colors.dark_bg}
      label_select_color=#${config.colors.background}
      unselectable_bg_color=#0000
      selectable_bg_color=#${config.colors.green}cc
      selectable_border_color=#${config.colors.green}cc
      label_font_family=monospace
      label_font_size=14 50% 100
    '';
  };
}
