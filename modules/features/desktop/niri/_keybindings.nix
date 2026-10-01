{pkgs, ...}: {
  wayland.windowManager.niri.settings.binds = {
    "Mod+D".spawn = [
      "bash"
      "-c"
      "${pkgs.procps}/bin/pkill wofi || ${pkgs.wofi}/bin/wofi -aGS drun"
    ];

    # lock and suspend
    "Mod+Ctrl+Slash".spawn = ["systemctl" "suspend"];

    # window actions
    "Mod+Q".close-window = {};
    "Mod+F".fullscreen-window = {};
    "Mod+Ctrl+F".toggle-windowed-fullscreen = {};
    "Mod+C".center-column = {};
    "Mod+W".toggle-column-tabbed-display = {};
    "Mod+V".toggle-window-floating = {};
    "Mod+Shift+V".switch-focus-between-floating-and-tiling = {};

    # clipboard history
    "Mod+Ctrl+V".spawn = [
      "bash"
      "-c"
      ''
        selection="$(${pkgs.cliphist}/bin/cliphist list | ${pkgs.wofi}/bin/wofi --dmenu)" || exit
        [ -n "$selection" ] || exit
        printf '%s\n' "$selection" | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy
      ''
    ];
    "Mod+Space".toggle-overview = {};
    "Mod+O".toggle-overview = {};

    # monitors
    "Mod+E".focus-monitor-next = {};
    "Mod+Shift+E".move-window-to-monitor-next = {};
    "Mod+Ctrl+E".move-workspace-to-monitor-next = {};

    # window size
    "Mod+R".switch-preset-column-width = {};
    "Mod+Ctrl+R".switch-preset-window-height = {};
    "Mod+Period".switch-preset-column-width = {};
    "Mod+TouchpadScrollDown".set-window-width = "-50";
    "Mod+WheelScrollDown".set-window-width = "-50";
    "Mod+Comma".switch-preset-column-width-back = {};
    "Mod+TouchpadScrollUp".set-window-width = "+50";
    "Mod+WheelScrollUp".set-window-width = "+50";
    "Mod+M".maximize-window-to-edges = {};
    "Mod+Ctrl+M".expand-column-to-available-width = {};

    # window casting
    "Mod+S".set-dynamic-cast-window = {};
    "Mod+Ctrl+S".set-dynamic-cast-monitor = {};
    "Mod+Shift+S".clear-dynamic-cast-target = {};

    # screenshots
    "Print".screenshot = {};
    "Ctrl+Print".screenshot-window = {};

    # focus
    "Mod+H".focus-column-left = {};
    "Mod+J".focus-window-or-workspace-down = {};
    "Mod+K".focus-window-or-workspace-up = {};
    "Mod+L".focus-column-right = {};
    "Mod+Left".focus-column-left = {};
    "Mod+Down".focus-window-or-workspace-down = {};
    "Mod+Up".focus-window-or-workspace-up = {};
    "Mod+Right".focus-column-right = {};

    # small move
    "Mod+Shift+H".consume-or-expel-window-left = {};
    "Mod+Shift+L".consume-or-expel-window-right = {};
    "Mod+Shift+J".spawn = ["fish" "-c" "niri msg -j windows | jq -er '.[]|select(.is_focused==true)|.is_floating' && niri msg action move-window-to-workspace-down || niri msg action move-window-down-or-to-workspace-down"];
    "Mod+Shift+K".spawn = ["fish" "-c" "niri msg -j windows | jq -er '.[]|select(.is_focused==true)|.is_floating' && niri msg action move-window-to-workspace-up || niri msg action move-window-up-or-to-workspace-up"];
    "Mod+Shift+Left".consume-or-expel-window-left = {};
    "Mod+Shift+Right".consume-or-expel-window-right = {};
    "Mod+Shift+Down".spawn = ["fish" "-c" "niri msg -j windows | jq -er '.[]|select(.is_focused==true)|.is_floating' && niri msg action move-window-to-workspace-down || niri msg action move-window-down-or-to-workspace-down"];
    "Mod+Shift+Up".spawn = ["fish" "-c" "niri msg -j windows | jq -er '.[]|select(.is_focused==true)|.is_floating' && niri msg action move-window-to-workspace-up || niri msg action move-window-up-or-to-workspace-up"];

    # large move
    # "Mod+Ctrl+H".move-column-left-or-to-monitor-left = {};
    "Mod+Ctrl+J".move-workspace-down = {};
    "Mod+Ctrl+K".move-workspace-up = {};
    # "Mod+Ctrl+L".move-column-right-or-to-monitor-right = {};
    "Mod+Ctrl+H".spawn = ["fish" "-c" "niri msg -j windows | jq -er '.[]|select(.is_focused==true)|.is_floating' && niri msg action move-window-to-monitor-left || niri msg action move-column-left-or-to-monitor-left"];
    "Mod+Ctrl+L".spawn = ["fish" "-c" "niri msg -j windows | jq -er '.[]|select(.is_focused==true)|.is_floating' && niri msg action move-window-to-monitor-right || niri msg action move-column-right-or-to-monitor-right"];
    "Mod+Ctrl+Down".move-workspace-down = {};
    "Mod+Ctrl+Up".move-workspace-up = {};
    "Mod+Ctrl+Left".spawn = ["fish" "-c" "niri msg -j windows | jq -er '.[]|select(.is_focused==true)|.is_floating' && niri msg action move-window-to-monitor-left || niri msg action move-column-left-or-to-monitor-left"];
    "Mod+Ctrl+Right".spawn = ["fish" "-c" "niri msg -j windows | jq -er '.[]|select(.is_focused==true)|.is_floating' && niri msg action move-window-to-monitor-right || niri msg action move-column-right-or-to-monitor-right"];

    # laptop screen
    "Mod+Equal".spawn = ["niri" "msg" "output" "eDP-1" "on"];
    "Mod+Shift+Equal".spawn = ["niri" "msg" "output" "eDP-1" "off"];

    # replace three finger scroll
    "Mod+Ctrl+WheelScrollDown" = {
      _props.cooldown-ms = 150;
      focus-workspace-down = {};
    };
    "Mod+Ctrl+WheelScrollUp" = {
      _props.cooldown-ms = 150;
      focus-workspace-up = {};
    };

    # workspace addresses, 0 is last with window, minus is the empty workspace
    # focus
    "Mod+1".focus-workspace = 1;
    "Mod+2".focus-workspace = 2;
    "Mod+3".focus-workspace = 3;
    "Mod+4".focus-workspace = 4;
    "Mod+5".focus-workspace = 5;
    "Mod+6".focus-workspace = 6;
    "Mod+7".focus-workspace = 7;
    "Mod+8".focus-workspace = 8;
    "Mod+9".focus-workspace = 9;
    "Mod+0".focus-workspace = 42;

    # small move
    "Mod+Shift+1".move-window-to-workspace = 1;
    "Mod+Shift+2".move-window-to-workspace = 2;
    "Mod+Shift+3".move-window-to-workspace = 3;
    "Mod+Shift+4".move-window-to-workspace = 4;
    "Mod+Shift+5".move-window-to-workspace = 5;
    "Mod+Shift+6".move-window-to-workspace = 6;
    "Mod+Shift+7".move-window-to-workspace = 7;
    "Mod+Shift+8".move-window-to-workspace = 8;
    "Mod+Shift+9".move-window-to-workspace = 9;
    "Mod+Shift+0".move-window-to-workspace = 42;

    # escape from keylocks
    "Mod+Escape" = {
      _props.allow-inhibiting = false;
      toggle-keyboard-shortcuts-inhibit = {};
    };

    # quit
    "Ctrl+Alt+Delete" = {
      _props.allow-inhibiting = false;
      quit = {};
    };
  };
}
