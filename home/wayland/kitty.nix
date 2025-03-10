{
  config,
  pkgs,
  ...
}: {
  programs.kitty = {
    enable = true;
    font = {
      name = "Iosevka";
      size = 12;
    };
    settings = {
      symbol_map =
        "U+23fb-U+23fe,U+2665,U+26a1,U+2b58,U+e000-U+e00a,U+e0a0-U+e0a2,U+e0a3,U+e0b0-U+e0b3,U+e0b4-U+e0c8,U+e0ca,U+e0cc-U+e0d7,U+e200-U+e2a9,U+e300-U+e3e3,U+e5fa-U+e6b5,U+e700-U+e7c5,U+ea60-U+ec1e,U+ed00-U+efc1,U+f000-U+f2ff,U+f300-U+f372,U+f400-U+f533,U+f500-U+fd46,U+f0001-U+f1af0,U+276c-U+2771,U+2500-U+259f,U+274C Symbols Nerd Font Mono";

      # make the font slightly wider
      # modify_font = "cell_width 105%";

      # this is how to use opentype features
      font_features = "Iosevka cv99=6 cv85=8";

      # basics
      cursor_trail = 100;
      cursor_trail_decay = "0.3 0.3";
      cursor_trail_start_threshold = 16;
      close_on_child_death = "yes";
      focus_follows_mouse = "no";
      enable_audio_bell = "no";
      confirm_os_window_close = 0;

      # disable ligatures at cursor
      disable_ligatures = "cursor";

      # scrollback
      scrollback_lines = "4000";
      scrollback_pager_history_size = "50";
      scrollback_fill_enlarged_window = "yes";
      scrollback_pager = "${pkgs.writeScript "pager.sh" ''
        #!/usr/bin/env bash
        set -eu

        if [ "$#" -eq 3 ]; then
            INPUT_LINE_NUMBER=''\${1:-0}
            CURSOR_LINE=''\${2:-1}
            CURSOR_COLUMN=''\${3:-1}
            AUTOCMD_TERMCLOSE_CMD="call cursor(max([0,''\${INPUT_LINE_NUMBER}-1])+''\${CURSOR_LINE}, ''\${CURSOR_COLUMN})"
        else
            AUTOCMD_TERMCLOSE_CMD="normal G"
        fi

        exec nvim 63<&0 0</dev/null \
            -c "map <silent> q :qa!<CR>" \
            -c "set shell=bash scrollback=100000 termguicolors laststatus=0 clipboard+=unnamedplus" \
            -c "autocmd TermEnter * stopinsert" \
            -c "autocmd TermClose * ''\${AUTOCMD_TERMCLOSE_CMD}" \
            -c 'terminal sed </dev/fd/63 -e "s/'$'\x1b''\'''\']8;;file:[^\]*[\]//g" && sleep 0.01 && printf "'$'\x1b''\'''\']2;"'
      ''} 'INPUT_LINE_NUMBER' 'CURSOR_LINE' 'CURSOR_COLUMN'";

      # selection
      strip_trailing_spaces = "smart";
      copy_on_select = "yes";

      # no default mappings
      clear_all_shortcuts = "yes";

      # my theme
      color0 = "#${config.colors.black}";
      color1 = "#${config.colors.red}";
      color2 = "#${config.colors.green}";
      color3 = "#${config.colors.yellow}";
      color4 = "#${config.colors.blue}";
      color5 = "#${config.colors.purple}";
      color6 = "#${config.colors.cyan}";
      color7 = "#${config.colors.white}";
      color8 = "#${config.colors.bright-black}";
      color9 = "#${config.colors.bright-red}";
      color10 = "#${config.colors.bright-green}";
      color11 = "#${config.colors.bright-yellow}";
      color12 = "#${config.colors.bright-blue}";
      color13 = "#${config.colors.bright-purple}";
      color14 = "#${config.colors.bright-cyan}";
      color15 = "#${config.colors.bright-white}";
      active_border_color = "#${config.colors.blue}";
      active_tab_background = "#${config.colors.blue}";
      active_tab_foreground = "#${config.colors.background}";
      background = "#${config.colors.background}";
      bell_border_color = "#${config.colors.red}";
      cursor = "#${config.colors.white}";
      foreground = "#${config.colors.foreground}";
      inactive_border_color = "#${config.colors.dark_bg}";
      inactive_tab_background = "#${config.colors.background}";
      inactive_tab_foreground = "#${config.colors.bright-black}";
      mark1_background = "#${config.colors.bright-red}";
      mark1_foreground = "#${config.colors.background}";
      mark2_background = "#${config.colors.bright-yellow}";
      mark2_foreground = "#${config.colors.background}";
      mark3_background = "#${config.colors.bright-green}";
      mark3_foreground = "#${config.colors.background}";
      selection_background = "#${config.colors.bright-black}";
      selection_foreground = "#${config.colors.white}";
      tab_bar_background = "#${config.colors.dark_bg}";
      tab_bar_margin_color = "#${config.colors.background}";
      url_color = "#${config.colors.bright-blue}";
    };
    extraConfig = ''
      mouse_map left click ungrabbed mouse_handle_click selection link prompt
    '';
    keybindings = {
      # os windows
      "ctrl+shift+n" = "launch --type=os-window --cwd=current";
      "alt+n" = "launch --type=os-window --cwd=current";
      "alt+r" = "set_window_title";

      # clipboard
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";

      # scrolling
      "shift+page_up" = "scroll_page_up";
      "shift+page_down" = "scroll_page_down";
      "shift+end" = "scroll_end";
      "alt+page_up" = "scroll_to_prompt -1";
      "alt+page_down" = "scroll_to_prompt +1";

      # font size
      "ctrl+shift+equal" = "change_font_size current +2.0";
      "ctrl+shift+minus" = "change_font_size current -2.0";
      "ctrl+shift+0" = "change_font_size current 0";
      "alt+equal" = "change_font_size current +2.0";
      "alt+minus" = "change_font_size current -2.0";
      "alt+0" = "change_font_size current 0";

      # dump output to vim
      "alt+h" = "show_scrollback";

      # paste things
      "alt+g" = "kitten hints --hints-text-color=red --type hash --program -";
      "alt+w" = "kitten hints --hints-text-color=red --type word --program -";
      "alt+l" = "kitten hints --hints-text-color=red --type line --program -";

      # quick actions
      "alt+f" = "kitten hints --hints-text-color=red --type path";
      "ctrl+shift+e" = "kitten hints --hints-text-color=red --type url --program default";
      "alt+u" = "kitten hints --hints-text-color=red --type url --program default";
      "alt+shift+u" = "kitten unicode_input";

      # markers
      "ctrl+shift+m" = "create_marker";
      "ctrl+shift+," = "remove_marker";
      "alt+f1" = "toggle_marker iregex 1 \\\\berr(or)?\\\\b 2 \\\\bwarn(ing)?\\\\b 3 \\\\b(info|debug|trace)\\\\b";
    };
  };
}
