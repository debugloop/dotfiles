{
  config,
  pkgs,
  ...
}: {
  programs.niri = {
    package = pkgs.niri-unstable;
    settings = {
      spawn-at-startup = [
        {
          command = ["${pkgs.xwayland-satellite}/bin/xwayland-satellite" ":42"];
        }
      ];
      environment = {
        DISPLAY = ":42";
      };
      screenshot-path = "~/pictures/screenshot-%d-%m-%Y-%T.png";
      input = {
        workspace-auto-back-and-forth = true;
        focus-follows-mouse = {
          enable = true;
          max-scroll-amount = "0%";
        };
        keyboard = {
          xkb = {
            layout = "us";
            model = "pc105";
            variant = "altgr-intl";
            options = "compose:rctrl,lv3:caps_switch";
          };
        };
        touchpad = {
          accel-profile = "adaptive";
          accel-speed = 0.4;
          tap = true;
          dwt = true;
          middle-emulation = true;
          natural-scroll = false;
        };
      };
      outputs = {
        "eDP-1" = {
          scale = 1.0;
          background-color = "#${config.colors.dark_bg}";
        };
        "DP-1" = {
          background-color = "#${config.colors.dark_bg}";
        };
      };
      hotkey-overlay.skip-at-startup = true;
      prefer-no-csd = true;
      layout = {
        # empty-workspace-above-first = true;
        gaps = 0;
        shadow = {
          enable = false;
          color = "#${config.colors.blue}";
          inactive-color = "#${config.colors.light_bg}00"; # transparent
          spread = 1;
          softness = 15;
          offset = {
            x = 0;
            y = 0;
          };
        };
        focus-ring = {
          enable = true;
          width = 1;
          active.color = "#${config.colors.blue}00";
          inactive.color = "#${config.colors.cyan}";
        };
        border = {
          enable = true;
          width = 1;
          active.color = "#${config.colors.blue}";
          inactive.color = "#${config.colors.light_bg}";
        };
        default-column-width.proportion = 0.3333;
        preset-column-widths = [
          {proportion = 0.3333;}
          {proportion = 0.5;}
          {proportion = 0.6667;}
        ];
        preset-window-heights = [
          {proportion = 0.2;}
          {proportion = 0.4;}
          {proportion = 0.6;}
          {proportion = 0.8;}
        ];
        tab-indicator = {
          position = "right";
          gap = -8.0;
          width = 5;
          gaps-between-tabs = 5;
          length.total-proportion = 0.1;
          corner-radius = 5;
          active.color = "#${config.colors.blue}88";
          inactive.color = "#${config.colors.light_bg}88";
        };
        insert-hint.display.color = "#${config.colors.green}88";
      };
      window-rules = [
        {
          clip-to-geometry = true;
          geometry-corner-radius = {
            bottom-left = 1.0;
            bottom-right = 1.0;
            top-left = 1.0;
            top-right = 1.0;
          };
        }
        {
          matches = [
            {is-window-cast-target = true;}
          ];
          border = {
            active.color = "#${config.colors.bright-red}";
            inactive.color = "#${config.colors.red}";
          };
          shadow = {
            enable = true;
            color = "#${config.colors.red}";
          };
        }
        {
          matches = [
            {is-floating = true;}
          ];
          shadow = {
            enable = true;
            color = "#${config.colors.blue}";
          };
        }
      ];
      layer-rules = [
        {
          matches = [
            {namespace = "notifications";}
          ];
          block-out-from = "screen-capture";
        }
      ];
      # workspaces = {
      #   "1-web" = {
      #     name = "web";
      #   };
      #   "2-com" = {
      #     name = "com";
      #   };
      # };
      binds = with config.lib.niri.actions; {
        "Mod+D".action = spawn "${pkgs.wofi}/bin/wofi" "-aGS" "drun";
        "Mod+Return".action = spawn "${pkgs.kitty}/bin/kitty";

        # Keys consist of modifiers separated by + signs, followed by an XKB key name
        # in the end. To find an XKB name for a particular key, you may use a program
        # like wev.
        #
        # "Mod" is a special modifier equal to Super when running on a TTY, and to Alt
        # when running as a winit window.
        #
        # Most actions that you can bind here can also be invoked programmatically with
        # `niri msg action do-something`.

        "Mod+Backslash".action = spawn "${pkgs.swaylock-effects}/bin/swaylock" "-f";
        "Mod+Ctrl+Shift+Backslash".action = spawn "systemctl" "suspend";
        "Cancel".action = spawn "${pkgs.swaylock-effects}/bin/swaylock" "-f";

        "XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action = spawn "bash" "-c" "${pkgs.avizo}/bin/volumectl -M0 up 1 && pkill -SIGRTMIN+4 waybar";
        };
        "XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action = spawn "bash" "-c" "${pkgs.avizo}/bin/volumectl -M0 down 1 && pkill -SIGRTMIN+4 waybar";
        };
        "Shift+XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action = spawn "bash" "-c" "${pkgs.avizo}/bin/volumectl -M0 up 5 && pkill -SIGRTMIN+4 waybar";
        };
        "Shift+XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action = spawn "bash" "-c" "${pkgs.avizo}/bin/volumectl -M0 down 5 && pkill -SIGRTMIN+4 waybar";
        };
        "XF86AudioMute" = {
          allow-when-locked = true;
          action = spawn "bash" "-c" "${pkgs.avizo}/bin/volumectl -M0 toggle-mute && pkill -SIGRTMIN+4 waybar";
        };
        "XF86AudioMicMute" = {
          allow-when-locked = true;
          action = spawn "bash" "-c" "${pkgs.avizo}/bin/volumectl -M0 -m toggle-mute && pkill -SIGRTMIN+4 waybar";
        };

        "XF86AudioPlay" = {
          allow-when-locked = true;
          action = spawn "${pkgs.playerctl}/bin/playerctl" "-p" "spotify" "play-pause";
        };
        "XF86AudioNext" = {
          allow-when-locked = true;
          action = spawn "${pkgs.playerctl}/bin/playerctl" "-p" "spotify" "next";
        };
        "XF86AudioPrev" = {
          allow-when-locked = true;
          action = spawn "${pkgs.playerctl}/bin/playerctl" "-p" "spotify" "previous";
        };
        "XF86AudioStop" = {
          allow-when-locked = true;
          action = spawn "${pkgs.playerctl}/bin/playerctl" "-p" "spotify" "stop";
        };

        "Mod+XF86AudioRaiseVolume".action = set-column-width "+1%";
        "Mod+XF86AudioLowerVolume".action = set-column-width "-1%";
        "Mod+Shift+XF86AudioRaiseVolume".action = set-window-height "+1%";
        "Mod+Shift+XF86AudioLowerVolume".action = set-window-height "-1%";

        "Mod+Q".action = close-window;

        # "Mod+Left".action = focus-column-left;
        # "Mod+Down".action = focus-window-down;
        # "Mod+Up".action = focus-window-up;
        # "Mod+Right".action = focus-column-right;
        # focus

        "Mod+H".action = focus-column-left-or-last;
        # "Mod+H".action = focus-column-or-monitor-left;
        # combined:
        # "Mod+H".action = spawn "fish" "-c" "niri msg -j outputs | jq -r '[.[]|select(.current_mode!=null)]|length' | grep 1; and niri msg action focus-column-left-or-last; or niri msg action focus-column-or-monitor-left";
        "Mod+Semicolon".action = spawn "fish" "-c" "niri msg action focus-window --id (niri msg -j windows | jq -r '.[] | (.id|tostring) + \" \" + .app_id + \": \" + .title' | ${pkgs.wofi}/bin/wofi -di | cut -d' ' -f1)";

        # "Mod+J".action = focus-window-down-or-top;
        # "Mod+J".action = focus-window-or-monitor-down;
        "Mod+J".action = focus-window-or-workspace-down;
        # combined:
        # "Mod+J".action = spawn "fish" "-c" "niri msg -j outputs | jq -r '[.[]|select(.current_mode!=null)]|length' | grep 1; and niri msg action focus-window-down-or-top; or niri msg action focus-window-or-monitor-down";

        # "Mod+K".action = focus-window-up-or-bottom;
        # "Mod+K".action = focus-window-or-monitor-up;
        "Mod+K".action = focus-window-or-workspace-up;
        # combined:
        # "Mod+K".action = spawn "fish" "-c" "niri msg -j outputs | jq -r '[.[]|select(.current_mode!=null)]|length' | grep 1; and niri msg action focus-window-up-or-bottom; or niri msg action focus-window-or-monitor-up";

        "Mod+L".action = focus-column-right-or-first;
        # "Mod+L".action = focus-column-or-monitor-right;
        # combined:
        # "Mod+L".action = spawn "fish" "-c" "niri msg -j outputs | jq -r '[.[]|select(.current_mode!=null)]|length' | grep 1; and niri msg action focus-column-right-or-first; or niri msg action focus-column-or-monitor-right";

        # move
        "Mod+Shift+H".action = consume-or-expel-window-left;
        "Mod+Shift+L".action = consume-or-expel-window-right;
        "Mod+Shift+J".action = move-window-down-or-to-workspace-down;
        "Mod+Shift+K".action = move-window-up-or-to-workspace-up;

        # workspaces
        "Mod+Ctrl+H".action = move-workspace-up;
        "Mod+Ctrl+L".action = move-workspace-down;
        # "Mod+Ctrl+J".action = focus-workspace-down;
        # "Mod+Ctrl+K".action = focus-workspace-up;
        "Mod+Ctrl+J".action = spawn "fish" "-c" "niri msg -j workspaces | jq -r 'sort_by(.idx).[-2].is_focused' | grep true; and niri msg action focus-workspace (niri msg -j workspaces | jq -r 'sort_by(.idx).[0].idx'); or niri msg action focus-workspace-down";
        "Mod+Ctrl+K".action = spawn "fish" "-c" "niri msg -j workspaces | jq -r 'sort_by(.idx).[0].is_focused' | grep true; and niri msg action focus-workspace (niri msg -j workspaces | jq -r 'sort_by(.idx).[-2].idx'); or niri msg action focus-workspace-up";
        # "Mod+Ctrl+J".action = move-column-left-or-to-monitor-left;
        # "Mod+Ctrl+K".action = move-column-right-or-to-monitor-right;

        # monitors
        "Mod+Shift+Ctrl+H".action = move-workspace-to-monitor-left;
        "Mod+Shift+Ctrl+J".action = move-workspace-to-monitor-down;
        "Mod+Shift+Ctrl+K".action = move-workspace-to-monitor-up;
        "Mod+Shift+Ctrl+L".action = move-workspace-to-monitor-right;

        # swap columns
        "Mod+BracketRight".action = move-column-right-or-to-monitor-right;
        "Mod+BracketLeft".action = move-column-left-or-to-monitor-left;

        # special focus and movement large
        "Mod+Backspace".action = focus-column-first;
        "Mod+Ctrl+Backspace".action = move-column-to-first;
        "Mod+Delete".action = focus-column-last;
        "Mod+Ctrl+Delete".action = move-column-to-last;

        "Mod+Equal".action = spawn "niri" "msg" "output" "eDP-1" "on";
        "Mod+Shift+Equal".action = spawn "niri" "msg" "output" "eDP-1" "off";

        # "Mod+Ctrl+Page_Down".action = move-column-to-workspace-down;
        # "Mod+Ctrl+Page_Up".action = move-column-to-workspace-up;

        # Alternative commands that move across workspaces when reaching
        # the first or last window in a column.

        # "Mod+Shift+Left".action = focus-monitor-left;
        # "Mod+Shift+Down".action = focus-monitor-down;
        # "Mod+Shift+Up".action = focus-monitor-up;
        # "Mod+Shift+Right".action = focus-monitor-right;
        # "Mod+Shift+H".action = focus-monitor-left;
        # "Mod+Shift+J".action = focus-monitor-down;
        # "Mod+Shift+K".action = focus-monitor-up;
        # "Mod+Shift+L".action = focus-monitor-right;

        # "Mod+Shift+Ctrl+Left".action = move-column-to-monitor-left;
        # "Mod+Shift+Ctrl+Down".action = move-column-to-monitor-down;
        # "Mod+Shift+Ctrl+Up".action = move-column-to-monitor-up;
        # "Mod+Shift+Ctrl+Right".action = move-column-to-monitor-right;

        # Alternatively, there are commands to move just a single window:
        # Mod+Shift+Ctrl+Left  { move-window-to-monitor-left; }
        # ...

        # And you can also move a whole workspace to another monitor:
        # Mod+Shift+Ctrl+Left  { move-workspace-to-monitor-left; }
        # ...

        # "Mod+Page_Down".action = focus-workspace-down;
        # "Mod+Page_Up".action = focus-workspace-up;
        # "Mod+U".action = focus-workspace-down;
        # "Mod+I".action = focus-workspace-up;
        # "Mod+Ctrl+Page_Down".action = move-column-to-workspace-down;
        # "Mod+Ctrl+Page_Up".action = move-column-to-workspace-up;
        # "Mod+Ctrl+U".action = move-column-to-workspace-down;
        # "Mod+Ctrl+I".action = move-column-to-workspace-up;

        # Alternatively, there are commands to move just a single window:
        # Mod+Ctrl+Page_Down { move-window-to-workspace-down; }
        # ...

        # "Mod+Shift+Page_Down".action = move-workspace-down;
        # "Mod+Shift+Page_Up".action = move-workspace-up;
        # "Mod+Shift+U".action = move-workspace-down;
        # "Mod+Shift+I".action = move-workspace-up;

        # You can bind mouse wheel scroll ticks using the following syntax.
        # These binds will change direction based on the natural-scroll setting.
        #
        # To avoid scrolling through workspaces really fast, you can use
        # the cooldown-ms property. The bind will be rate-limited to this value.
        # You can set a cooldown on any bind, but it's most useful for the wheel.
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
        "Mod+Shift+TouchpadScrollDown" = {
          cooldown-ms = 150;
          action = focus-column-right;
        };
        "Mod+Shift+TouchpadScrollUp" = {
          cooldown-ms = 150;
          action = focus-column-left;
        };
        "Mod+TouchpadScrollDown" = {
          cooldown-ms = 150;
          action = focus-workspace-down;
        };
        "Mod+TouchpadScrollUp" = {
          cooldown-ms = 150;
          action = focus-workspace-up;
        };

        # Similarly, you can bind touchpad scroll "ticks".
        # Touchpad scrolling is continuous, so for these binds it is split into
        # discrete intervals.
        # These binds are also affected by touchpad's natural-scroll, so these
        # example binds are "inverted", since we have natural-scroll enabled for
        # touchpads by default.
        # Mod+TouchpadScrollDown { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.02+"; }
        # Mod+TouchpadScrollUp   { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.02-"; }

        # You can refer to workspaces by index. However, keep in mind that
        # niri is a dynamic workspace system, so these commands are kind of
        # "best effort". Trying to refer to a workspace index bigger than
        # the current workspace count will instead refer to the bottommost
        # (empty) workspace.
        #
        # For example, with 2 workspaces + 1 empty, indices 3, 4, 5 and so on
        # will all refer to the 3rd workspace.
        "Mod+1".action = focus-workspace 1;
        "Mod+2".action = focus-workspace 2;
        "Mod+3".action = focus-workspace 3;
        "Mod+4".action = focus-workspace 4;
        "Mod+5".action = focus-workspace 5;
        "Mod+6".action = focus-workspace 6;
        "Mod+7".action = focus-workspace 7;
        "Mod+8".action = focus-workspace 8;
        "Mod+9".action = focus-workspace 9;
        "Mod+0".action = spawn "fish" "-c" "niri msg action focus-workspace (niri msg -j workspaces | jq -r 'sort_by(.idx).[-2].idx')";
        "Mod+Minus".action = focus-workspace 42;
        "Mod+Ctrl+1".action = move-column-to-workspace 1;
        "Mod+Ctrl+2".action = move-column-to-workspace 2;
        "Mod+Ctrl+3".action = move-column-to-workspace 3;
        "Mod+Ctrl+4".action = move-column-to-workspace 4;
        "Mod+Ctrl+5".action = move-column-to-workspace 5;
        "Mod+Ctrl+6".action = move-column-to-workspace 6;
        "Mod+Ctrl+7".action = move-column-to-workspace 7;
        "Mod+Ctrl+8".action = move-column-to-workspace 8;
        "Mod+Ctrl+9".action = move-column-to-workspace 9;
        "Mod+Ctrl+0".action = spawn "fish" "-c" "niri msg action move-column-to-workspace (niri msg -j workspaces | jq -r 'sort_by(.idx).[-2].idx')";
        "Mod+Ctrl+Minus".action = move-column-to-workspace 42;
        "Mod+Shift+1".action = move-window-to-workspace 1;
        "Mod+Shift+2".action = move-window-to-workspace 2;
        "Mod+Shift+3".action = move-window-to-workspace 3;
        "Mod+Shift+4".action = move-window-to-workspace 4;
        "Mod+Shift+5".action = move-window-to-workspace 5;
        "Mod+Shift+6".action = move-window-to-workspace 6;
        "Mod+Shift+7".action = move-window-to-workspace 7;
        "Mod+Shift+8".action = move-window-to-workspace 8;
        "Mod+Shift+9".action = move-window-to-workspace 9;
        "Mod+Shift+0".action = spawn "fish" "-c" "niri msg action move-window-to-workspace (niri msg -j workspaces | jq -r 'sort_by(.idx).[-2].idx')";
        "Mod+Shift+Minus".action = move-window-to-workspace 42;

        # Alternatively, there are commands to move just a single window:
        # Mod+Ctrl+1 { move-window-to-workspace 1; }

        # Switches focus between the current and the previous workspace.
        "Mod+Tab".action = focus-monitor-next;

        # Consume one window from the right to the bottom of the focused column.
        # "Mod+Comma".action = consume-window-into-column;
        # Expel the bottom window from the focused column to the right.
        # "Mod+Period".action = expel-window-from-column;

        "Mod+R".action = switch-preset-column-width;
        "Mod+Shift+R".action = switch-preset-window-height;
        "Mod+M".action = maximize-column;
        "Mod+Shift+M".action = reset-window-height;
        "Mod+Comma".action = set-column-width "33.33%";
        "Mod+Period".action = set-column-width "66.67%";
        "Mod+Slash".action = set-column-width "50%";

        "Mod+F".action = fullscreen-window;
        "Mod+Ctrl+F".action = toggle-windowed-fullscreen;
        "Mod+Shift+F".action = toggle-windowed-fullscreen;
        "Mod+C".action = center-column;

        # Finer width adjustments.
        # This command can also:
        # * set width in pixels: "1000"
        # * adjust width in pixels: "-5" or "+5"
        # * set width as a percentage of screen width: "25%"
        # * adjust width as a percentage of screen width: "-10%" or "+10%"
        # Pixel sizes use logical, or scaled, pixels. I.e. on an output with scale 2.0,
        # set-column-width "100" will make the column occupy 200 physical screen pixels.
        # "Mod+Minus".action = set-column-width "-10%";
        # "Mod+Equal".action = set-column-width "+10%";

        # Finer height adjustments when in column with other windows.
        # "Mod+Shift+Minus".action = set-window-height "-10%";
        # "Mod+Shift+Equal".action = set-window-height "+10%";

        # Move the focused window between the floating and the tiling layout.
        "Mod+V".action = toggle-window-floating;
        "Mod+Space".action = switch-focus-between-floating-and-tiling;

        "Mod+S".action = set-dynamic-cast-window;
        "Mod+Ctrl+S".action = set-dynamic-cast-monitor;
        "Mod+Shift+S".action = clear-dynamic-cast-target;

        # Toggle tabbed column display mode.
        # Windows in this column will appear as vertical tabs,
        # rather than stacked on top of each other.
        "Mod+W".action = toggle-column-tabbed-display;

        # Actions to switch keyboard layouts.
        # Note: if you uncomment these, make sure you do NOT have
        # a matching layout switch hotkey configured in xkb options above.
        # Having both at once on the same hotkey will break the switching,
        # since it will switch twice upon pressing the hotkey (once by xkb, once by niri).
        # Mod+Space       { switch-layout "next"; }
        # Mod+Shift+Space { switch-layout "prev"; }

        "Print".action = screenshot;
        # "Ctrl+Print".action = screenshot-screen true;
        "Alt+Print".action = screenshot-window;

        # Applications such as remote-desktop clients and software KVM switches may
        # request that niri stops processing the keyboard shortcuts defined here
        # so they may, for example, forward the key presses as-is to a remote machine.
        # It's a good idea to bind an escape hatch to toggle the inhibitor,
        # so a buggy application can't hold your session hostage.
        #
        # The allow-inhibiting=false property can be applied to other binds as well,
        # which ensures niri always processes them, even when an inhibitor is active.
        "Mod+Escape" = {
          allow-inhibiting = false;
          action = toggle-keyboard-shortcuts-inhibit;
        };

        # The quit action will show a confirmation dialog to avoid accidental exits.
        "Ctrl+Alt+Delete" = {
          allow-inhibiting = false;
          action = quit;
        };
      };
    };
  };
}
