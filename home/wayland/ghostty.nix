{
  config,
  inputs,
  pkgs,
  ...
}: {
  home.packages = [
    inputs.ghostty.packages.${pkgs.system}.default
    pkgs.chafa
  ];

  xdg.configFile."ghostty/config".text = ''
    palette = 0=#${config.colors.black}
    palette = 1=#${config.colors.red}
    palette = 2=#${config.colors.green}
    palette = 3=#${config.colors.yellow}
    palette = 4=#${config.colors.blue}
    palette = 5=#${config.colors.purple}
    palette = 6=#${config.colors.cyan}
    palette = 7=#${config.colors.white}
    palette = 8=#${config.colors.bright-black}
    palette = 9=#${config.colors.bright-red}
    palette = 10=#${config.colors.bright-green}
    palette = 11=#${config.colors.bright-yellow}
    palette = 12=#${config.colors.bright-blue}
    palette = 13=#${config.colors.bright-purple}
    palette = 14=#${config.colors.bright-cyan}
    palette = 15=#${config.colors.bright-white}
    background = ${config.colors.background}
    foreground = ${config.colors.foreground}
    cursor-color = ${config.colors.white}
    selection-foreground = ${config.colors.white}

    gtk-titlebar = false
    window-decoration = false
    resize-overlay = never
    window-padding-balance = true
    window-padding-color = extend

    font-synthetic-style = false
    font-family = "Iosevka"
    font-style = "Medium"
    font-style-bold = "Extrabold"
    font-style-italic = "Medium Italic"
    font-style-bold-italic = "Extrabold Italic"
    font-feature = -calt
    font-feature = -liga
    font-feature = -dlig
    font-variation = cv99=6
    font-variation = cv85=8
    adjust-cell-width = 5%

    font-family = "Symbols Nerd Font Mono"

    auto-update = off

    # clipboard
    keybind = ctrl+shift+a=select_all
    keybind = ctrl+shift+c=copy_to_clipboard
    keybind = ctrl+shift+v=paste_from_clipboard

    # usability
    keybind = ctrl+shift+n=new_window
    keybind = ctrl+shift+j=write_scrollback_file:paste

    keybind = ctrl+page_up=jump_to_prompt:-1
    keybind = ctrl+page_down=jump_to_prompt:1
    keybind = shift+page_down=scroll_page_down
    keybind = shift+page_up=scroll_page_up
    keybind = shift+end=scroll_to_bottom


    # goodies
    keybind = ctrl+shift+i=inspector:toggle
    keybind = ctrl+shift+comma=reload_config

    # fonts
    keybind = ctrl+equal=increase_font_size:1
    keybind = ctrl+plus=increase_font_size:1
    keybind = ctrl+minus=decrease_font_size:1
    keybind = ctrl+zero=reset_font_size

    # selection
    keybind = shift+up=adjust_selection:up
    keybind = shift+down=adjust_selection:down
    keybind = shift+left=adjust_selection:left
    keybind = shift+right=adjust_selection:right

    # unbind defaults
    keybind = alt+f4=unbind
    keybind = alt+one=unbind
    keybind = alt+two=unbind
    keybind = alt+three=unbind
    keybind = alt+four=unbind
    keybind = alt+five=unbind
    keybind = alt+six=unbind
    keybind = alt+seven=unbind
    keybind = alt+eight=unbind
    keybind = alt+nine=unbind
    keybind = ctrl+alt+down=unbind
    keybind = ctrl+alt+left=unbind
    keybind = ctrl+alt+right=unbind
    keybind = ctrl+alt+shift+j=unbind
    keybind = ctrl+alt+up=unbind
    keybind = ctrl+comma=unbind
    keybind = ctrl+enter=unbind
    keybind = ctrl+shift+e=unbind
    keybind = ctrl+shift+enter=unbind
    keybind = ctrl+shift+left=unbind
    keybind = ctrl+shift+o=unbind
    keybind = ctrl+shift+q=unbind
    keybind = ctrl+shift+right=unbind
    keybind = ctrl+shift+t=unbind
    keybind = ctrl+shift+tab=unbind
    keybind = ctrl+shift+w=unbind
    keybind = ctrl+tab=unbind
    keybind = shift+insert=unbind
    keybind = shift+home=unbind
    keybind = super+ctrl+left_bracket=unbind
    keybind = super+ctrl+right_bracket=unbind
    keybind = super+ctrl+shift+down=unbind
    keybind = super+ctrl+shift+equal=unbind
    keybind = super+ctrl+shift+left=unbind
    keybind = super+ctrl+shift+right=unbind
    keybind = super+ctrl+shift+up=unbind
  '';
}
