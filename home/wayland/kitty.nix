{config, ...}: {
  programs.kitty = {
    enable = true;
    font = {
      # name = "FiraCode Nerd Font";
      # name = "JetBrainsMono NFM";
      # size = 11;
      name = "Iosevka"; # no NFM here, as the NFM variant is behind on versions
      size = 12;
    };
    settings = {
      # generated from https://github.com/ryanoasis/nerd-fonts/wiki/Glyph-Sets-and-Code-Points
      symbol_map = "U+23fb-U+23fe,U+2665,U+26a1,U+2b58,U+e000-U+e00a,U+e0a0-U+e0a2,U+e0a3,U+e0b0-U+e0b3,U+e0b4-U+e0c8,U+e0ca,U+e0cc-U+e0d7,U+e200-U+e2a9,U+e300-U+e3e3,U+e5fa-U+e6b5,U+e700-U+e7c5,U+ea60-U+ec1e,U+ed00-U+efc1,U+f000-U+f2ff,U+f300-U+f372,U+f400-U+f533,U+f500-U+fd46,U+f0001-U+f1af0,U+276c-U+2771,U+2500-U+259f,U+274C IosevkaNFM"; # the last entry is ❌, which we wanna have it it's flat, no-color variant

      # make the font slightly wider
      modify_font = "cell_width 105%";

      # this is how to use opentype features
      font_features = "Iosevka cv99=6 cv85=8";

      # basics
      # cursor_trail = 100;
      # cursor_trail_decay = "0.3 0.3";
      # cursor_trail_start_threshold = 16;
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
      scrollback_pager = "bash -c \"exec nvim 63<&0 0</dev/null -c 'autocmd TermEnter * stopinsert' -c 'autocmd TermClose * call cursor(max([0,INPUT_LINE_NUMBER-1])+CURSOR_LINE, CURSOR_COLUMN)' -c 'terminal sed </dev/fd/63 -e \\\"s/'$'\\x1b'']8 file:[^\\]*[\\]//g\\\" && sleep 0.01 && printf \\\"'$'\\x1b'']2;\\\"' -c 'set modifiable'\"";

      # selection
      strip_trailing_spaces = "smart";
      copy_on_select = "yes";

      # layouts
      enabled_layouts = "tall,fat,vertical,horizontal,grid,splits,stack";

      # tab style
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      tab_title_template = "{fmt.fg.red}{bell_symbol}{activity_symbol}{fmt.fg.tab}{'*' if layout_name == 'stack' and num_windows > 1 else ''}{index}: {tab.active_exe}";
      active_tab_font_style = "bold";

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
      "alt+f1" = "toggle_marker iregex 1 \\\\berr(or)?\\\\b 2 \\\\bwarn(ing)?\\\\b 3 \\\\b(info|debug|trace)\\\\b";
      "alt+f2" = "toggle_marker regex 1 \\\\bOOMKilled\\\\b 2 \\\\bTerminated\\\\b 3 \\\\bRunning\\\\b";

      # os windows
      "ctrl+shift+n" = "launch --type=os-window --cwd=current";
      "ctrl+shift+r" = "set_window_title";

      # clipboard
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";

      # scrolling
      "ctrl+page_up" = "scroll_page_up";
      "ctrl+page_down" = "scroll_page_down";
      "ctrl+shift+page_up" = "scroll_home";
      "ctrl+shift+page_down" = "scroll_end";
      "ctrl+shift+[" = "scroll_to_prompt -1";
      "ctrl+shift+]" = "scroll_to_prompt +1";

      # dump output to vim
      "ctrl+shift+h" = "show_scrollback";
      "ctrl+shift+g" = "show_last_command_output";

      # font size
      "ctrl+shift+equal" = "change_font_size current +2.0";
      "ctrl+shift+minus" = "change_font_size current -2.0";
      "ctrl+shift+0" = "change_font_size current 0";

      # paste things
      "ctrl+shift+p>h" = "kitten hints --type hash --program -";
      "ctrl+shift+p>w" = "kitten hints --type word --program -";
      "ctrl+shift+p>l" = "kitten hints --type line --program -";
      "ctrl+shift+p>p" = "kitten hints --type path --program -";

      # quick actions
      "ctrl+shift+u" = "kitten unicode_input";
      "ctrl+shift+e" = "open_url_with_hints";
      "ctrl+shift+o" = "kitten hints --type linenum";

      # markers
      "ctrl+shift+m" = "create_marker";
      "ctrl+shift+," = "remove_marker";

      # not used in tiling wm:
      # tabs
      "ctrl+shift+enter" = "new_tab_with_cwd";
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+j" = "previous_tab";
      "ctrl+shift+k" = "next_tab";
      "ctrl+shift+right" = "move_tab_forward";
      "ctrl+shift+left" = "move_tab_backward";

      # pane creation and navigation
      "alt+enter" = "launch --location=vsplit --cwd=current";
      "shift+alt+enter" = "launch --location=vsplit";
      "shift+alt+v" = "launch --location=hsplit";
      "alt+h" = "neighboring_window left";
      "alt+j" = "neighboring_window down";
      "alt+k" = "neighboring_window up";
      "alt+l" = "neighboring_window right";
      "alt+tab" = "focus_visible_window";
      "alt+m" = "swap_with_window";
      "alt+d" = "detach_window new-tab";

      # pane resizing
      "alt+r" = "resize_window reset";
      "shift+alt+r" = "start_resizing_window";
      "alt+up" = "resize_window taller";
      "alt+down" = "resize_window shorter";
      "alt+right" = "resize_window wider";
      "alt+left" = "resize_window narrower";
      "shift+alt+up" = "resize_window taller 8";
      "shift+alt+down" = "resize_window shorter 8";
      "shift+alt+right" = "resize_window wider 5";
      "shift+alt+left" = "resize_window narrower 5";

      # select layouts
      "alt+backspace" = "next_layout";
      "alt+space" = "toggle_layout stack";
      "alt+t" = "goto_layout tall";
      "shift+alt+t" = "goto_layout tall:bias=70;mirrored=true";
      "alt+f" = "goto_layout fat";
      "shift+alt+f" = "goto_layout fat:bias=70";
      "alt+s" = "goto_layout splits";
      "alt+g" = "goto_layout grid";

      # layout actions
      "alt+[" = "layout_action decrease_num_full_size_windows";
      "alt+]" = "layout_action increase_num_full_size_windows";
      "alt+backslash" = "layout_action mirror toggle";
      "alt+b" = "layout_action bias 30 40 50 60 70 80";

      # directly jump to windows and tabs
      "alt+`" = "nth_window -1";
      "alt+1" = "nth_window 0";
      "alt+2" = "nth_window 1";
      "alt+3" = "nth_window 2";
      "alt+4" = "nth_window 3";
      "alt+5" = "nth_window 4";
      "alt+6" = "nth_window 5";
      "alt+7" = "nth_window 6";
      "alt+8" = "nth_window 7";
      "alt+9" = "nth_window 8";
      "alt+0" = "nth_window 9";
      "ctrl+shift+`" = "goto_tab -1";
      "ctrl+shift+1" = "goto_tab 1";
      "ctrl+shift+2" = "goto_tab 2";
      "ctrl+shift+3" = "goto_tab 3";
      "ctrl+shift+4" = "goto_tab 4";
      "ctrl+shift+5" = "goto_tab 5";
      "ctrl+shift+6" = "goto_tab 6";
      "ctrl+shift+7" = "goto_tab 7";
      "ctrl+shift+8" = "goto_tab 8";
      "ctrl+shift+9" = "goto_tab 9";
    };
  };
}
