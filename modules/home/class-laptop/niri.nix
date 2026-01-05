{
  config,
  pkgs,
  perSystem,
  ...
}: {
  home.packages = with pkgs; [
    xwayland-satellite
  ];
  services.swww.enable = true;
  programs.niri = {
    package = perSystem.niri.niri-unstable;
    settings = {
      gestures.hot-corners.enable = false;
      screenshot-path = "~/pictures/screenshot-%d-%m-%Y-%T.png";
      input = {
        workspace-auto-back-and-forth = true;
        # warp-mouse-to-focus.enable = true;
        focus-follows-mouse = {
          enable = true;
          max-scroll-amount = "0%";
        };
        keyboard = {
          xkb = {
            layout = "eu";
            options = "compose:rctrl,lv3:ralt_switch_multikey";
          };
        };
        touchpad = {
          accel-profile = "adaptive";
          accel-speed = 0.4;
          tap = true;
          dwt = true;
          middle-emulation = true;
          natural-scroll = true;
        };
      };
      overview.backdrop-color = "#${config.colors.light_bg}";
      outputs = {
        "eDP-1" = {
          scale = 1.0;
          background-color = "#${config.colors.dark_bg}";
        };
        "DP-1" = {
          background-color = "#${config.colors.dark_bg}";
        };
        "DP-2" = {
          background-color = "#${config.colors.dark_bg}";
        };
      };
      hotkey-overlay.skip-at-startup = true;
      prefer-no-csd = true;
      layout = {
        empty-workspace-above-first = true;
        always-center-single-column = true;
        gaps = 12;
        struts = {
          top = -6;
          bottom = -6;
          left = -6;
          right = -6;
        };
        shadow = {
          enable = false;
          color = "#${config.colors.blue}";
          inactive-color = "#${config.colors.light_bg}00"; # transparent
        };
        focus-ring = {
          enable = true;
          width = 2;
          active.color = "#${config.colors.blue}";
          inactive.color = "#${config.colors.cyan}";
          urgent.color = "#${config.colors.red}";
        };
        border = {
          enable = false;
          width = 1;
          active.color = "#${config.colors.blue}00";
          inactive.color = "#${config.colors.light_bg}00";
          urgent.color = "#${config.colors.red}";
        };
        default-column-width.proportion = 0.4;
        preset-column-widths = [
          {proportion = 0.3;}
          {proportion = 0.4;}
          {proportion = 0.5;}
          {proportion = 0.6;}
          {proportion = 0.7;}
        ];
        preset-window-heights = [
          {proportion = 0.333333;}
          {proportion = 0.5;}
          {proportion = 0.666667;}
        ];
        tab-indicator = {
          position = "top";
          place-within-column = true;
          gap = 5;
          width = 4;
          gaps-between-tabs = 8;
          length.total-proportion = 0.3;
          corner-radius = 5;
          active.color = "#${config.colors.blue}";
          inactive.color = "#${config.colors.light_bg}";
          urgent.color = "#${config.colors.red}";
        };
        insert-hint.display.color = "#${config.colors.green}88";
      };
      debug = {
        honor-xdg-activation-with-invalid-serial = true;
      };
      window-rules = [
        {
          clip-to-geometry = true;
          geometry-corner-radius = {
            bottom-left = 0.0;
            bottom-right = 10.0;
            top-left = 10.0;
            top-right = 0.0;
          };
        }
        {
          matches = [
            {title = "^\\[private\\] .*$";}
          ];
          block-out-from = "screencast";
        }
        {
          matches = [
            {
              title = "Picture-in-Picture";
              app-id = "firefox";
            }
          ];
          open-floating = true;
        }
        {
          matches = [
            {app-id = "kitty";}
          ];
          default-column-width = {proportion = 0.3;};
        }
        {
          matches = [
            {is-urgent = true;}
          ];
          shadow = {
            enable = true;
            softness = 0;
            spread = 2;
            offset = {
              x = 0;
              y = 0;
            };
            color = "#${config.colors.bright-red}";
          };
        }
        {
          matches = [
            {is-window-cast-target = true;}
          ];
          focus-ring = {
            enable = true;
            width = 1;
            active.color = "#${config.colors.bright-red}";
            inactive.color = "#${config.colors.bright-red}";
          };
          border = {
            enable = true;
            width = 1;
            active.color = "#${config.colors.bright-red}00";
            inactive.color = "#${config.colors.bright-red}00";
          };
          shadow = {
            enable = true;
            softness = 8;
            spread = 3;
            offset = {
              x = 0;
              y = 0;
            };
            color = "#${config.colors.bright-red}";
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
        # launch
        "Mod+D".action = spawn "bash" "-c" "${pkgs.procps}/bin/pkill wofi || ${pkgs.wofi}/bin/wofi -aGS drun";
        "Mod+Return".action = spawn "${pkgs.kitty}/bin/kitty";

        # notifications
        "Mod+N".action = spawn "${pkgs.mako}/bin/makoctl" "dismiss" "-a";

        # lock and suspend
        "Mod+Backslash".action = spawn "${pkgs.swaylock-effects}/bin/swaylock" "-f";
        "Mod+Ctrl+Backslash".action = spawn "systemctl" "suspend";

        # window actions
        "Mod+Q".action = close-window;
        "Mod+F".action = fullscreen-window;
        "Mod+Ctrl+F".action = toggle-windowed-fullscreen;
        "Mod+Shift+F".action = toggle-windowed-fullscreen;
        "Mod+C".action = center-column;
        "Mod+W".action = toggle-column-tabbed-display;
        "Mod+Ctrl+V".action = toggle-window-floating;
        "Mod+V".action = switch-focus-between-floating-and-tiling;
        "Mod+Space".action = toggle-overview;

        # window width
        "Mod+R".action = switch-preset-column-width;
        "Mod+Period".action = switch-preset-column-width;
        "Mod+Comma".action = switch-preset-column-width-back;
        "Mod+M".action = maximize-window-to-edges;
        "Mod+Ctrl+M".action = expand-column-to-available-width;
        "Mod+XF86AudioRaiseVolume".action = switch-preset-column-width;
        "Mod+XF86AudioLowerVolume".action = switch-preset-column-width-back;

        # window height
        "Mod+Shift+R".action = switch-preset-window-height;
        "Mod+Shift+M".action = reset-window-height;
        "Mod+Shift+XF86AudioRaiseVolume".action = set-window-height "+1%";
        "Mod+Shift+XF86AudioLowerVolume".action = set-window-height "-1%";

        # window casting
        "Mod+S".action = set-dynamic-cast-window;
        "Mod+Ctrl+S".action = set-dynamic-cast-monitor;
        "Mod+Shift+S".action = clear-dynamic-cast-target;

        # find windows
        "Mod+Semicolon".action = spawn "fish" "-c" "niri msg action focus-window --id (niri msg -j windows | jq -r '.[] | (.id|tostring) + \" \" + .app_id + \": \" + .title' | ${pkgs.wofi}/bin/wofi -di | cut -d' ' -f1)";

        # screenshots
        "Print".action.screenshot = [];
        "Ctrl+Print".action.screenshot-window = [];

        # focus
        "Mod+Backspace".action = focus-column-first;
        "Mod+Shift+Backspace".action = focus-column-last;
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

        # monitors
        # "Mod+Tab".action = focus-monitor-next;
        # "Mod+Shift+Tab".action = move-window-to-monitor-next;
        # "Mod+Ctrl+Tab".action = move-workspace-to-monitor-next;

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

        # colorcode workspaces
        # "Mod+Ctrl+Grave".action = unset-workspace-name;
        "Mod+Ctrl+1".action = set-workspace-name "red";
        "Mod+Ctrl+2".action = set-workspace-name "green";
        "Mod+Ctrl+3".action = set-workspace-name "blue";
        "Mod+Ctrl+4".action = set-workspace-name "orange";
        "Mod+Ctrl+7".action = set-workspace-name "pink";
        "Mod+Ctrl+8".action = set-workspace-name "cyan";
        "Mod+Ctrl+9".action = set-workspace-name "purple";
        "Mod+Ctrl+0".action = set-workspace-name "yellow";
        "Mod+Ctrl+Minus".action = unset-workspace-name;
        # TODO: flake support for these?
        "Mod+Shift+1".action = spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"red\")' && niri msg action move-window-to-workspace red || niri msg action move-window-to-workspace 42 && niri msg action set-workspace-name red";
        "Mod+Shift+2".action = spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"green\")' && niri msg action move-window-to-workspace green || niri msg action move-window-to-workspace 42 && niri msg action set-workspace-name green";
        "Mod+Shift+3".action = spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"blue\")' && niri msg action move-window-to-workspace blue || niri msg action move-window-to-workspace 42 && niri msg action set-workspace-name blue";
        "Mod+Shift+4".action = spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"orange\")' && niri msg action move-window-to-workspace orange || niri msg action move-window-to-workspace 42 && niri msg action set-workspace-name orange";
        "Mod+Shift+7".action = spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"pink\")' && niri msg action move-window-to-workspace pink || niri msg action move-window-to-workspace 42 && niri msg action set-workspace-name pink";
        "Mod+Shift+8".action = spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"cyan\")' && niri msg action move-window-to-workspace cyan || niri msg action move-window-to-workspace 42 && niri msg action set-workspace-name cyan";
        "Mod+Shift+9".action = spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"purple\")' && niri msg action move-window-to-workspace purple || niri msg action move-window-to-workspace 42 && niri msg action set-workspace-name purple";
        "Mod+Shift+0".action = spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"yellow\")' && niri msg action move-window-to-workspace yellow || niri msg action move-window-to-workspace 42 && niri msg action set-workspace-name yellow";
        "Mod+Shift+Minus".action = spawn "fish" "-c" "niri msg action move-window-to-workspace 42";
        # "Mod+1".action = focus-workspace "red";
        "Mod+1".action = spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"red\")' && niri msg action focus-workspace red || niri msg action focus-workspace 64 && niri msg action set-workspace-name red";
        "Mod+2".action = spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"green\")' && niri msg action focus-workspace green || niri msg action focus-workspace 64 && niri msg action set-workspace-name green";
        "Mod+3".action = spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"blue\")' && niri msg action focus-workspace blue || niri msg action focus-workspace 64 && niri msg action set-workspace-name blue";
        "Mod+4".action = spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"orange\")' && niri msg action focus-workspace orange || niri msg action focus-workspace 64 && niri msg action set-workspace-name orange";
        "Mod+7".action = spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"pink\")' && niri msg action focus-workspace pink || niri msg action focus-workspace 64 && niri msg action set-workspace-name pink";
        "Mod+8".action = spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"cyan\")' && niri msg action focus-workspace cyan || niri msg action focus-workspace 64 && niri msg action set-workspace-name cyan";
        "Mod+9".action = spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"purple\")' && niri msg action focus-workspace purple || niri msg action focus-workspace 64 && niri msg action set-workspace-name purple";
        "Mod+0".action = spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"yellow\")' && niri msg action focus-workspace yellow || niri msg action focus-workspace 64 && niri msg action set-workspace-name yellow";
        "Mod+Minus".action = focus-workspace 42;

        # # workspace addresses, 0 is last with window, minus is the empty workspace
        # # focus
        # "Mod+1".action = focus-workspace 1;
        # "Mod+2".action = focus-workspace 2;
        # "Mod+3".action = focus-workspace 3;
        # "Mod+4".action = focus-workspace 4;
        # "Mod+5".action = focus-workspace 5;
        # "Mod+6".action = focus-workspace 6;
        # "Mod+7".action = focus-workspace 7;
        # "Mod+8".action = focus-workspace 8;
        # "Mod+9".action = focus-workspace 9;
        # "Mod+0".action = spawn "fish" "-c" "niri msg action focus-workspace (niri msg -j workspaces | jq -r 'sort_by(.idx).[-2].idx')";
        # "Mod+Minus".action = focus-workspace 42;
        #
        # # small move
        # "Mod+Shift+1".action = move-window-to-workspace 1;
        # "Mod+Shift+2".action = move-window-to-workspace 2;
        # "Mod+Shift+3".action = move-window-to-workspace 3;
        # "Mod+Shift+4".action = move-window-to-workspace 4;
        # "Mod+Shift+5".action = move-window-to-workspace 5;
        # "Mod+Shift+6".action = move-window-to-workspace 6;
        # "Mod+Shift+7".action = move-window-to-workspace 7;
        # "Mod+Shift+8".action = move-window-to-workspace 8;
        # "Mod+Shift+9".action = move-window-to-workspace 9;
        # "Mod+Shift+0".action = spawn "fish" "-c" "niri msg action move-window-to-workspace (niri msg -j workspaces | jq -r 'sort_by(.idx).[-2].idx')";
        # "Mod+Shift+Minus".action = move-window-to-workspace 42;
        #
        # # large move
        # "Mod+Ctrl+1".action = move-column-to-workspace 1;
        # "Mod+Ctrl+2".action = move-column-to-workspace 2;
        # "Mod+Ctrl+3".action = move-column-to-workspace 3;
        # "Mod+Ctrl+4".action = move-column-to-workspace 4;
        # "Mod+Ctrl+5".action = move-column-to-workspace 5;
        # "Mod+Ctrl+6".action = move-column-to-workspace 6;
        # "Mod+Ctrl+7".action = move-column-to-workspace 7;
        # "Mod+Ctrl+8".action = move-column-to-workspace 8;
        # "Mod+Ctrl+9".action = move-column-to-workspace 9;
        # "Mod+Ctrl+0".action = spawn "fish" "-c" "niri msg action move-column-to-workspace (niri msg -j workspaces | jq -r 'sort_by(.idx).[-2].idx')";
        # "Mod+Ctrl+Minus".action = move-column-to-workspace 42;

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

        # media and brightness
        "XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action = spawn "bash" "-c" "${pkgs.swayosd}/bin/swayosd-client --output-volume=1 && pkill -SIGRTMIN+4 waybar";
        };
        "XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action = spawn "bash" "-c" "${pkgs.swayosd}/bin/swayosd-client --output-volume=-1 && pkill -SIGRTMIN+4 waybar";
        };
        "Shift+XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action = spawn "bash" "-c" "${pkgs.swayosd}/bin/swayosd-client --output-volume=5 && pkill -SIGRTMIN+4 waybar";
        };
        "Shift+XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action = spawn "bash" "-c" "${pkgs.swayosd}/bin/swayosd-client --output-volume=-5 && pkill -SIGRTMIN+4 waybar";
        };
        "XF86AudioMute" = {
          allow-when-locked = true;
          action = spawn "bash" "-c" "${pkgs.swayosd}/bin/swayosd-client --output-volume=mute-toggle && pkill -SIGRTMIN+4 waybar";
        };
        "XF86AudioMicMute" = {
          allow-when-locked = true;
          action = spawn "bash" "-c" "${pkgs.swayosd}/bin/swayosd-client --input-volume=mute-toggle && pkill -SIGRTMIN+4 waybar";
        };
        "XF86AudioPlay" = {
          allow-when-locked = true;
          action = spawn "${pkgs.swayosd}/bin/swayosd-client" "--playerctl=play-pause";
        };
        "XF86AudioNext" = {
          allow-when-locked = true;
          action = spawn "${pkgs.swayosd}/bin/swayosd-client" "--playerctl=next";
        };
        "XF86AudioPrev" = {
          allow-when-locked = true;
          action = spawn "${pkgs.swayosd}/bin/swayosd-client" "--playerctl=prev";
        };
        "XF86AudioStop" = {
          allow-when-locked = true;
          action = spawn "${pkgs.swayosd}/bin/swayosd-client" "--playerctl=play-pause";
        };
        "XF86MonBrightnessUp" = {
          action = spawn "${pkgs.swayosd}/bin/swayosd-client" "--brightness=raise";
        };
        "XF86MonBrightnessDown" = {
          action = spawn "${pkgs.swayosd}/bin/swayosd-client" "--brightness=lower";
        };
      };
    };
  };
}
