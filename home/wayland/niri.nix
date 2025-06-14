{
  config,
  pkgs,
  ...
}: {
  programs.niri = {
    package = pkgs.niri-unstable;
    config = ''
      gestures {
          hot-corners {
              off
          }
      }
      input {
          keyboard {
              xkb {
                  layout "us"
                  model "pc105"
                  rules ""
                  variant "altgr-intl"
                  options "compose:rctrl,lv3:caps_switch"
              }
              repeat-delay 600
              repeat-rate 25
              track-layout "global"
          }
          touchpad {
              tap
              dwt
              natural-scroll
              middle-emulation
              accel-speed 0.400000
              accel-profile "adaptive"
          }
          mouse { accel-speed 0.000000; }
          trackpoint { accel-speed 0.000000; }
          trackball { accel-speed 0.000000; }
          tablet
          touch
          focus-follows-mouse max-scroll-amount="0%"
          workspace-auto-back-and-forth
      }
      output "DP-1" {
          background-color "#16161d"
          transform "normal"
      }
      output "DP-2" {
          background-color "#16161d"
          transform "normal"
      }
      output "eDP-1" {
          background-color "#16161d"
          scale 1.000000
          transform "normal"
      }
      screenshot-path "~/pictures/screenshot-%d-%m-%Y-%T.png"
      prefer-no-csd
      layout {
          gaps 0
          struts {
              left 0
              right 0
              top 0
              bottom 0
          }
          focus-ring {
              width 1
              active-color "#7e9cd800"
              inactive-color "#6a9589"
          }
          border {
              width 2
              active-color "#7e9cd8"
              inactive-color "#363646"
          }
          tab-indicator {
              place-within-column
              gap 0
              width 5
              length total-proportion=0.200000
              position "right"
              gaps-between-tabs 5
              corner-radius 5
              active-color "#7e9cd8ff"
              inactive-color "#363646ff"
          }
          insert-hint { color "#76946a88"; }
          default-column-width { proportion 0.333000; }
          preset-column-widths {
              proportion 0.333000
              proportion 0.500000
              proportion 0.667000
          }
          preset-window-heights {
              proportion 0.333000
              proportion 0.500000
              proportion 0.667000
          }
          center-focused-column "never"
          empty-workspace-above-first
      }
      cursor {
          xcursor-theme "default"
          xcursor-size 24
      }
      hotkey-overlay { skip-at-startup; }
      environment { DISPLAY ":42"; }
      binds {
          Cancel { spawn "/nix/store/p8bvcrx0ibsidagf5c6pzqcq3xhqi56a-swaylock-effects-1.7.0.0/bin/swaylock" "-f"; }
          Ctrl+Alt+Delete allow-inhibiting=false { quit; }
          Ctrl+Print { screenshot-window; }
          Mod+0 { spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"yellow\")' && niri msg action focus-workspace yellow || niri msg action focus-workspace 42 && niri msg action set-workspace-name yellow"; }
          Mod+1 { spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"red\")' && niri msg action focus-workspace red || niri msg action focus-workspace 42 && niri msg action set-workspace-name red"; }
          Mod+2 { spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"green\")' && niri msg action focus-workspace green || niri msg action focus-workspace 42 && niri msg action set-workspace-name green"; }
          Mod+3 { spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"blue\")' && niri msg action focus-workspace blue || niri msg action focus-workspace 42 && niri msg action set-workspace-name blue"; }
          Mod+4 { spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"orange\")' && niri msg action focus-workspace orange || niri msg action focus-workspace 42 && niri msg action set-workspace-name orange"; }
          Mod+7 { spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"pink\")' && niri msg action focus-workspace pink || niri msg action focus-workspace 42 && niri msg action set-workspace-name pink"; }
          Mod+8 { spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"cyan\")' && niri msg action focus-workspace cyan || niri msg action focus-workspace 42 && niri msg action set-workspace-name cyan"; }
          Mod+9 { spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"purple\")' && niri msg action focus-workspace purple || niri msg action focus-workspace 42 && niri msg action set-workspace-name purple"; }
          Mod+Backslash { spawn "/nix/store/p8bvcrx0ibsidagf5c6pzqcq3xhqi56a-swaylock-effects-1.7.0.0/bin/swaylock" "-f"; }
          Mod+BracketLeft { focus-column-first; }
          Mod+BracketRight { focus-column-last; }
          Mod+C { center-column; }
          Mod+Comma { set-column-width "33.3%"; }
          Mod+Ctrl+0 { set-workspace-name "yellow"; }
          Mod+Ctrl+1 { set-workspace-name "red"; }
          Mod+Ctrl+2 { set-workspace-name "green"; }
          Mod+Ctrl+3 { set-workspace-name "blue"; }
          Mod+Ctrl+4 { set-workspace-name "orange"; }
          Mod+Ctrl+7 { set-workspace-name "pink"; }
          Mod+Ctrl+8 { set-workspace-name "cyan"; }
          Mod+Ctrl+9 { set-workspace-name "purple"; }
          Mod+Ctrl+F { toggle-windowed-fullscreen; }
          Mod+Ctrl+H { spawn "fish" "-c" "niri msg -j windows | jq -er '.[]|select(.is_focused==true)|.is_floating' && niri msg action move-window-to-monitor-left || niri msg action move-column-left-or-to-monitor-left"; }
          Mod+Ctrl+J { move-workspace-down; }
          Mod+Ctrl+K { move-workspace-up; }
          Mod+Ctrl+L { spawn "fish" "-c" "niri msg -j windows | jq -er '.[]|select(.is_focused==true)|.is_floating' && niri msg action move-window-to-monitor-right || niri msg action move-column-right-or-to-monitor-right"; }
          Mod+Ctrl+M { expand-column-to-available-width; }
          Mod+Ctrl+Minus { unset-workspace-name; }
          Mod+Ctrl+S { set-dynamic-cast-monitor; }
          Mod+Ctrl+Shift+Backslash { spawn "systemctl" "suspend"; }
          Mod+Ctrl+Tab { move-workspace-to-monitor-next; }
          Mod+Ctrl+V { toggle-window-floating; }
          Mod+D { spawn "bash" "-c" "/nix/store/x3bxjpkcbfyzmy5695g1cchf04fbz8ca-procps-4.0.4/bin/pkill wofi || /nix/store/rmzqxydwi93w4sph4hz3k4cq4zn8yfl5-wofi-1.4.1/bin/wofi -aGS drun"; }
          Mod+Equal { spawn "niri" "msg" "output" "eDP-1" "on"; }
          Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
          Mod+F { fullscreen-window; }
          Mod+H { focus-column-or-monitor-left; }
          Mod+J { focus-window-or-workspace-down; }
          Mod+K { focus-window-or-workspace-up; }
          Mod+L { focus-column-or-monitor-right; }
          Mod+M { maximize-column; }
          Mod+Minus { focus-workspace 42; }
          Mod+N { spawn "/nix/store/0jlav4ashclra6rz64xk6ydgybabfvdq-mako-1.10.0/bin/makoctl" "dismiss" "-a"; }
          Mod+Period { set-column-width "66.7%"; }
          Mod+Q { close-window; }
          Mod+R { switch-preset-column-width; }
          Mod+Return { spawn "/nix/store/n8sayk27r4dishnkw79l57f7hiskr47p-kitty-0.42.0/bin/kitty"; }
          Mod+S { set-dynamic-cast-window; }
          Mod+Semicolon { spawn "fish" "-c" "niri msg action focus-window --id (niri msg -j windows | jq -r '.[] | (.id|tostring) + \" \" + .app_id + \": \" + .title' | /nix/store/rmzqxydwi93w4sph4hz3k4cq4zn8yfl5-wofi-1.4.1/bin/wofi -di | cut -d' ' -f1)"; }
          Mod+Shift+0 { spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"yellow\")' && niri msg action move-window-to-workspace yellow || niri msg action move-window-to-workspace 42 && niri msg action set-workspace-name yellow"; }
          Mod+Shift+1 { spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"red\")' && niri msg action move-window-to-workspace red || niri msg action move-window-to-workspace 42 && niri msg action set-workspace-name red"; }
          Mod+Shift+2 { spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"green\")' && niri msg action move-window-to-workspace green || niri msg action move-window-to-workspace 42 && niri msg action set-workspace-name green"; }
          Mod+Shift+3 { spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"blue\")' && niri msg action move-window-to-workspace blue || niri msg action move-window-to-workspace 42 && niri msg action set-workspace-name blue"; }
          Mod+Shift+4 { spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"orange\")' && niri msg action move-window-to-workspace orange || niri msg action move-window-to-workspace 42 && niri msg action set-workspace-name orange"; }
          Mod+Shift+7 { spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"pink\")' && niri msg action move-window-to-workspace pink || niri msg action move-window-to-workspace 42 && niri msg action set-workspace-name pink"; }
          Mod+Shift+8 { spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"cyan\")' && niri msg action move-window-to-workspace cyan || niri msg action move-window-to-workspace 42 && niri msg action set-workspace-name cyan"; }
          Mod+Shift+9 { spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"purple\")' && niri msg action move-window-to-workspace purple || niri msg action move-window-to-workspace 42 && niri msg action set-workspace-name purple"; }
          Mod+Shift+BracketLeft { move-column-to-first; }
          Mod+Shift+BracketRight { move-column-to-last; }
          Mod+Shift+Equal { spawn "niri" "msg" "output" "eDP-1" "off"; }
          Mod+Shift+F { toggle-windowed-fullscreen; }
          Mod+Shift+H { consume-or-expel-window-left; }
          Mod+Shift+J { spawn "fish" "-c" "niri msg -j windows | jq -er '.[]|select(.is_focused==true)|.is_floating' && niri msg action move-window-to-workspace-down || niri msg action move-window-down-or-to-workspace-down"; }
          Mod+Shift+K { spawn "fish" "-c" "niri msg -j windows | jq -er '.[]|select(.is_focused==true)|.is_floating' && niri msg action move-window-to-workspace-up || niri msg action move-window-up-or-to-workspace-up"; }
          Mod+Shift+L { consume-or-expel-window-right; }
          Mod+Shift+M { reset-window-height; }
          Mod+Shift+Minus { spawn "fish" "-c" "niri msg action move-window-to-workspace 42"; }
          Mod+Shift+R { switch-preset-window-height; }
          Mod+Shift+S { clear-dynamic-cast-target; }
          Mod+Shift+Tab { move-window-to-monitor-next; }
          Mod+Shift+WheelScrollDown cooldown-ms=150 { focus-column-right; }
          Mod+Shift+WheelScrollUp cooldown-ms=150 { focus-column-left; }
          Mod+Shift+XF86AudioLowerVolume { set-window-height "-1%"; }
          Mod+Shift+XF86AudioRaiseVolume { set-window-height "+1%"; }
          Mod+Slash { set-column-width "50%"; }
          Mod+Space { toggle-overview; }
          Mod+Tab { focus-monitor-next; }
          Mod+V { switch-focus-between-floating-and-tiling; }
          Mod+W { toggle-column-tabbed-display; }
          Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
          Mod+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }
          Mod+XF86AudioLowerVolume { set-column-width "-1%"; }
          Mod+XF86AudioRaiseVolume { set-column-width "+1%"; }
          Print { screenshot; }
          Shift+XF86AudioLowerVolume allow-when-locked=true { spawn "bash" "-c" "/nix/store/fcrgnyg3zzxgjvasd3bga5pb6h4pw8nd-swayosd-0.2.0/bin/swayosd-client --output-volume=-5 && pkill -SIGRTMIN+4 waybar"; }
          Shift+XF86AudioRaiseVolume allow-when-locked=true { spawn "bash" "-c" "/nix/store/fcrgnyg3zzxgjvasd3bga5pb6h4pw8nd-swayosd-0.2.0/bin/swayosd-client --output-volume=5 && pkill -SIGRTMIN+4 waybar"; }
          XF86AudioLowerVolume allow-when-locked=true { spawn "bash" "-c" "/nix/store/fcrgnyg3zzxgjvasd3bga5pb6h4pw8nd-swayosd-0.2.0/bin/swayosd-client --output-volume=-1 && pkill -SIGRTMIN+4 waybar"; }
          XF86AudioMicMute allow-when-locked=true { spawn "bash" "-c" "/nix/store/fcrgnyg3zzxgjvasd3bga5pb6h4pw8nd-swayosd-0.2.0/bin/swayosd-client --input-volume=mute-toggle && pkill -SIGRTMIN+4 waybar"; }
          XF86AudioMute allow-when-locked=true { spawn "bash" "-c" "/nix/store/fcrgnyg3zzxgjvasd3bga5pb6h4pw8nd-swayosd-0.2.0/bin/swayosd-client --output-volume=mute-toggle && pkill -SIGRTMIN+4 waybar"; }
          XF86AudioNext allow-when-locked=true { spawn "/nix/store/fcrgnyg3zzxgjvasd3bga5pb6h4pw8nd-swayosd-0.2.0/bin/swayosd-client" "--playerctl=next"; }
          XF86AudioPlay allow-when-locked=true { spawn "/nix/store/fcrgnyg3zzxgjvasd3bga5pb6h4pw8nd-swayosd-0.2.0/bin/swayosd-client" "--playerctl=play-pause"; }
          XF86AudioPrev allow-when-locked=true { spawn "/nix/store/fcrgnyg3zzxgjvasd3bga5pb6h4pw8nd-swayosd-0.2.0/bin/swayosd-client" "--playerctl=prev"; }
          XF86AudioRaiseVolume allow-when-locked=true { spawn "bash" "-c" "/nix/store/fcrgnyg3zzxgjvasd3bga5pb6h4pw8nd-swayosd-0.2.0/bin/swayosd-client --output-volume=1 && pkill -SIGRTMIN+4 waybar"; }
          XF86AudioStop allow-when-locked=true { spawn "/nix/store/fcrgnyg3zzxgjvasd3bga5pb6h4pw8nd-swayosd-0.2.0/bin/swayosd-client" "--playerctl=play-pause"; }
          XF86MonBrightnessDown { spawn "/nix/store/fcrgnyg3zzxgjvasd3bga5pb6h4pw8nd-swayosd-0.2.0/bin/swayosd-client --brightness=lower"; }
          XF86MonBrightnessUp { spawn "/nix/store/fcrgnyg3zzxgjvasd3bga5pb6h4pw8nd-swayosd-0.2.0/bin/swayosd-client --brightness=raise"; }
      }
      spawn-at-startup "/nix/store/m3cbs4i4wx8y3jxkpfqz5qgnlf794hir-xwayland-satellite-0.5.1/bin/xwayland-satellite" ":42"
      window-rule {
          geometry-corner-radius 1.000000 1.000000 1.000000 1.000000
          clip-to-geometry true
      }
      window-rule {
          match title="^\\[private\\] .*$"
          block-out-from "screencast"
      }
      window-rule {
          match app-id="firefox" title="Picture-in-Picture"
          open-floating true
      }
      window-rule {
          match is-window-cast-target=true
          border {
              active-color "#e82424"
              inactive-color "#c34043"
          }
          shadow {
              on
              color "#c34043"
          }
      }
      window-rule {
          match is-floating=true
          shadow {
              on
              color "#7e9cd8"
          }
      }
      layer-rule {
          match namespace="notifications"
          block-out-from "screen-capture"
      }
      animations { slowdown 1.000000; }
    '';
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
          natural-scroll = true;
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
        "DP-2" = {
          background-color = "#${config.colors.dark_bg}";
        };
      };
      hotkey-overlay.skip-at-startup = true;
      prefer-no-csd = true;
      layout = {
        empty-workspace-above-first = true;
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
          width = 2;
          active.color = "#${config.colors.blue}";
          inactive.color = "#${config.colors.light_bg}";
        };
        default-column-width.proportion = 0.333;
        preset-column-widths = [
          {proportion = 0.333;}
          {proportion = 0.5;}
          {proportion = 0.667;}
        ];
        preset-window-heights = [
          {proportion = 0.333;}
          {proportion = 0.5;}
          {proportion = 0.667;}
        ];
        tab-indicator = {
          position = "right";
          place-within-column = true;
          gap = 0;
          width = 5;
          gaps-between-tabs = 5;
          length.total-proportion = 0.2;
          corner-radius = 5;
          active.color = "#${config.colors.blue}ff";
          inactive.color = "#${config.colors.light_bg}ff";
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
          # baba-is-float = true;
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
        "Mod+Ctrl+Shift+Backslash".action = spawn "systemctl" "suspend";
        "Cancel".action = spawn "${pkgs.swaylock-effects}/bin/swaylock" "-f";

        # window actions
        "Mod+Q".action = close-window;
        "Mod+F".action = fullscreen-window;
        "Mod+Ctrl+F".action = toggle-windowed-fullscreen;
        "Mod+Shift+F".action = toggle-windowed-fullscreen;
        "Mod+C".action = center-column;
        "Mod+W".action = toggle-column-tabbed-display;
        "Mod+Ctrl+V".action = toggle-window-floating;
        "Mod+V".action = switch-focus-between-floating-and-tiling;
        # "Mod+Space".action = spawn "${pkgs.writeScript "consume_next.py" ''
        #   #!/usr/bin/env python
        #   import subprocess
        #
        #   p = subprocess.Popen(['niri', 'msg', '-j', 'event-stream'], stdout=subprocess.PIPE)
        #
        #   for line in p.stdout:
        #       line = line.decode('utf-8')
        #       if 'WindowOpenedOrChanged' in line:
        #           subprocess.call(['niri', 'msg', 'action', 'consume-or-expel-window-left'])
        #           break
        # ''}";
        "Mod+Space".action = toggle-overview;

        # window width
        "Mod+R".action = switch-preset-column-width;
        "Mod+Comma".action = set-column-width "33.3%";
        "Mod+Period".action = set-column-width "66.7%";
        "Mod+Slash".action = set-column-width "50%";
        "Mod+M".action = maximize-column;
        "Mod+Ctrl+M".action = expand-column-to-available-width;
        "Mod+XF86AudioRaiseVolume".action = set-column-width "+1%";
        "Mod+XF86AudioLowerVolume".action = set-column-width "-1%";

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
        "Print".action = screenshot;
        "Ctrl+Print".action = screenshot-window;

        # focus
        # "Mod+H".action = focus-column-left-or-last;
        # "Mod+L".action = focus-column-right-or-first;
        "Mod+H".action = focus-column-or-monitor-left;
        "Mod+J".action = focus-window-or-workspace-down;
        "Mod+K".action = focus-window-or-workspace-up;
        "Mod+L".action = focus-column-or-monitor-right;

        # small move
        "Mod+Shift+H".action = consume-or-expel-window-left;
        "Mod+Shift+L".action = consume-or-expel-window-right;
        "Mod+Shift+J".action = spawn "fish" "-c" "niri msg -j windows | jq -er '.[]|select(.is_focused==true)|.is_floating' && niri msg action move-window-to-workspace-down || niri msg action move-window-down-or-to-workspace-down";
        "Mod+Shift+K".action = spawn "fish" "-c" "niri msg -j windows | jq -er '.[]|select(.is_focused==true)|.is_floating' && niri msg action move-window-to-workspace-up || niri msg action move-window-up-or-to-workspace-up";

        # large move
        # "Mod+Ctrl+H".action = move-column-left-or-to-monitor-left;
        "Mod+Ctrl+J".action = move-workspace-down;
        "Mod+Ctrl+K".action = move-workspace-up;
        # "Mod+Ctrl+L".action = move-column-right-or-to-monitor-right;
        "Mod+Ctrl+H".action = spawn "fish" "-c" "niri msg -j windows | jq -er '.[]|select(.is_focused==true)|.is_floating' && niri msg action move-window-to-monitor-left || niri msg action move-column-left-or-to-monitor-left";
        "Mod+Ctrl+L".action = spawn "fish" "-c" "niri msg -j windows | jq -er '.[]|select(.is_focused==true)|.is_floating' && niri msg action move-window-to-monitor-right || niri msg action move-column-right-or-to-monitor-right";

        # swaylike workspace focus with wrapping
        # "Mod+Ctrl+J".action = spawn "fish" "-c" "niri msg -j workspaces | jq -r 'sort_by(.idx).[-2].is_focused' | grep true; and niri msg action focus-workspace (niri msg -j workspaces | jq -r 'sort_by(.idx).[0].idx'); or niri msg action focus-workspace-down";
        # "Mod+Ctrl+K".action = spawn "fish" "-c" "niri msg -j workspaces | jq -r 'sort_by(.idx).[0].is_focused' | grep true; and niri msg action focus-workspace (niri msg -j workspaces | jq -r 'sort_by(.idx).[-2].idx'); or niri msg action focus-workspace-up";

        # monitors
        "Mod+Tab".action = focus-monitor-next;
        "Mod+Shift+Tab".action = move-window-to-monitor-next;
        "Mod+Ctrl+Tab".action = move-workspace-to-monitor-next;

        # special focus
        "Mod+BracketLeft".action = focus-column-first;
        "Mod+Shift+BracketLeft".action = move-column-to-first;
        "Mod+BracketRight".action = focus-column-last;
        "Mod+Shift+BracketRight".action = move-column-to-last;

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
        "Mod+1".action = spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"red\")' && niri msg action focus-workspace red || niri msg action focus-workspace 42 && niri msg action set-workspace-name red";
        "Mod+2".action = spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"green\")' && niri msg action focus-workspace green || niri msg action focus-workspace 42 && niri msg action set-workspace-name green";
        "Mod+3".action = spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"blue\")' && niri msg action focus-workspace blue || niri msg action focus-workspace 42 && niri msg action set-workspace-name blue";
        "Mod+4".action = spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"orange\")' && niri msg action focus-workspace orange || niri msg action focus-workspace 42 && niri msg action set-workspace-name orange";
        "Mod+7".action = spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"pink\")' && niri msg action focus-workspace pink || niri msg action focus-workspace 42 && niri msg action set-workspace-name pink";
        "Mod+8".action = spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"cyan\")' && niri msg action focus-workspace cyan || niri msg action focus-workspace 42 && niri msg action set-workspace-name cyan";
        "Mod+9".action = spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"purple\")' && niri msg action focus-workspace purple || niri msg action focus-workspace 42 && niri msg action set-workspace-name purple";
        "Mod+0".action = spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"yellow\")' && niri msg action focus-workspace yellow || niri msg action focus-workspace 42 && niri msg action set-workspace-name yellow";
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
          action = spawn "${pkgs.swayosd}/bin/swayosd-client --brightness=raise";
        };
        "XF86MonBrightnessDown" = {
          action = spawn "${pkgs.swayosd}/bin/swayosd-client --brightness=lower";
        };
      };
    };
  };
}
