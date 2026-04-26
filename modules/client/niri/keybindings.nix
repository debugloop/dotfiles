_: {
  flake.modules.homeManager.niri_keybindings = {
    config,
    pkgs,
    ...
  }: {
    programs.niri.settings.binds = with config.lib.niri.actions; {
      "Mod+D".action = spawn "bash" "-c" "${pkgs.procps}/bin/pkill wofi || ${pkgs.wofi}/bin/wofi -aGS drun";

      # lock and suspend
      "Mod+Ctrl+Backslash".action = spawn "systemctl" "suspend";

      # window actions
      "Mod+Q".action = close-window;
      "Mod+F".action = fullscreen-window;
      "Mod+Ctrl+F".action = toggle-windowed-fullscreen;
      "Mod+C".action = center-column;
      "Mod+W".action = toggle-column-tabbed-display;
      "Mod+Ctrl+V".action = toggle-window-floating;
      "Mod+V".action = switch-focus-between-floating-and-tiling;
      "Mod+Space".action = toggle-overview;
      "Mod+O".action = toggle-overview;

      # window size
      "Mod+R".action = switch-preset-column-width;
      "Mod+Ctrl+R".action = switch-preset-window-height;
      "Mod+Period".action = switch-preset-column-width;
      "Mod+Comma".action = switch-preset-column-width-back;
      "Mod+M".action = maximize-window-to-edges;
      "Mod+Ctrl+M".action = expand-column-to-available-width;
      "Mod+XF86AudioRaiseVolume".action = switch-preset-column-width;
      "Mod+XF86AudioLowerVolume".action = switch-preset-column-width-back;

      # window casting
      "Mod+S".action = set-dynamic-cast-window;
      "Mod+Ctrl+S".action = set-dynamic-cast-monitor;
      "Mod+Shift+S".action = clear-dynamic-cast-target;

      # screenshots
      "Print".action.screenshot = [];
      "Ctrl+Print".action.screenshot-window = [];

      # focus
      # TODO: missing from niri flake
      # "Mod+Backspace".action = next-window;
      # "Mod+Shift+Backspace".action = previous-window;
      # "Mod+Ctrl+Backspace".action = previous-window;
      "Mod+H".action = focus-column-or-monitor-left;
      "Mod+J".action = focus-window-or-workspace-down;
      "Mod+K".action = focus-window-or-workspace-up;
      "Mod+L".action = focus-column-or-monitor-right;
      "Mod+Left".action = focus-column-or-monitor-left;
      "Mod+Down".action = focus-window-or-workspace-down;
      "Mod+Up".action = focus-window-or-workspace-up;
      "Mod+Right".action = focus-column-or-monitor-right;

      # small move
      "Mod+Shift+H".action = consume-or-expel-window-left;
      "Mod+Shift+L".action = consume-or-expel-window-right;
      "Mod+Shift+J".action = spawn "fish" "-c" "niri msg -j windows | jq -er '.[]|select(.is_focused==true)|.is_floating' && niri msg action move-window-to-workspace-down || niri msg action move-window-down-or-to-workspace-down";
      "Mod+Shift+K".action = spawn "fish" "-c" "niri msg -j windows | jq -er '.[]|select(.is_focused==true)|.is_floating' && niri msg action move-window-to-workspace-up || niri msg action move-window-up-or-to-workspace-up";
      "Mod+Shift+Left".action = consume-or-expel-window-left;
      "Mod+Shift+Right".action = consume-or-expel-window-right;
      "Mod+Shift+Down".action = spawn "fish" "-c" "niri msg -j windows | jq -er '.[]|select(.is_focused==true)|.is_floating' && niri msg action move-window-to-workspace-down || niri msg action move-window-down-or-to-workspace-down";
      "Mod+Shift+Up".action = spawn "fish" "-c" "niri msg -j windows | jq -er '.[]|select(.is_focused==true)|.is_floating' && niri msg action move-window-to-workspace-up || niri msg action move-window-up-or-to-workspace-up";

      # large move
      # "Mod+Ctrl+H".action = move-column-left-or-to-monitor-left;
      "Mod+Ctrl+J".action = move-workspace-down;
      "Mod+Ctrl+K".action = move-workspace-up;
      # "Mod+Ctrl+L".action = move-column-right-or-to-monitor-right;
      "Mod+Ctrl+H".action = spawn "fish" "-c" "niri msg -j windows | jq -er '.[]|select(.is_focused==true)|.is_floating' && niri msg action move-window-to-monitor-left || niri msg action move-column-left-or-to-monitor-left";
      "Mod+Ctrl+L".action = spawn "fish" "-c" "niri msg -j windows | jq -er '.[]|select(.is_focused==true)|.is_floating' && niri msg action move-window-to-monitor-right || niri msg action move-column-right-or-to-monitor-right";
      "Mod+Ctrl+Down".action = move-workspace-down;
      "Mod+Ctrl+Up".action = move-workspace-up;
      "Mod+Ctrl+Left".action = spawn "fish" "-c" "niri msg -j windows | jq -er '.[]|select(.is_focused==true)|.is_floating' && niri msg action move-window-to-monitor-left || niri msg action move-column-left-or-to-monitor-left";
      "Mod+Ctrl+Right".action = spawn "fish" "-c" "niri msg -j windows | jq -er '.[]|select(.is_focused==true)|.is_floating' && niri msg action move-window-to-monitor-right || niri msg action move-column-right-or-to-monitor-right";

      # laptop screen
      "Mod+Equal".action = spawn "niri" "msg" "output" "eDP-1" "on";
      "Mod+Shift+Equal".action = spawn "niri" "msg" "output" "eDP-1" "off";

      # scrolling focus
      "Mod+Shift+WheelScrollDown" = {
        cooldown-ms = 150;
        action = focus-column-right;
      };
      "Mod+Shift+WheelScrollUp" = {
        cooldown-ms = 150;
        action = focus-column-left;
      };
      "Mod+WheelScrollDown" = {
        cooldown-ms = 150;
        action = focus-workspace-down;
      };
      "Mod+WheelScrollUp" = {
        cooldown-ms = 150;
        action = focus-workspace-up;
      };

      # workspace addresses, 0 is last with window, minus is the empty workspace
      # focus
      "Mod+1".action = focus-workspace 1;
      "Mod+2".action = focus-workspace 2;
      "Mod+3".action = focus-workspace 3;
      "Mod+4".action = focus-workspace 4;
      "Mod+5".action = focus-workspace 5;
      "Mod+6".action = focus-workspace 6;
      "Mod+7".action = focus-workspace 7;
      "Mod+8".action = focus-workspace 8;
      "Mod+9".action = focus-workspace 9;
      "Mod+0".action = focus-workspace 42;

      # small move
      "Mod+Shift+1".action.move-window-to-workspace = 1;
      "Mod+Shift+2".action.move-window-to-workspace = 2;
      "Mod+Shift+3".action.move-window-to-workspace = 3;
      "Mod+Shift+4".action.move-window-to-workspace = 4;
      "Mod+Shift+5".action.move-window-to-workspace = 5;
      "Mod+Shift+6".action.move-window-to-workspace = 6;
      "Mod+Shift+7".action.move-window-to-workspace = 7;
      "Mod+Shift+8".action.move-window-to-workspace = 8;
      "Mod+Shift+9".action.move-window-to-workspace = 9;
      "Mod+Shift+0".action.move-window-to-workspace = 42;

      # escape from keylocks
      "Mod+Escape" = {
        allow-inhibiting = false;
        action = toggle-keyboard-shortcuts-inhibit;
      };

      # quit
      "Ctrl+Alt+Delete" = {
        allow-inhibiting = false;
        action = quit;
      };
    };
  };
}
