{
  config,
  pkgs,
  ...
}: {
  wayland.windowManager.sway = {
    enable = false;
    extraConfigEarly = ''
      set $workspace1 "1:web"
      set $workspace2 "2:com"
      set $workspace3 "3:file"
      set $workspace4 "4:music"
      set $workspace5 "5:misc"
      set $workspace6 "6:misc"
      set $workspace7 "7:term"
      set $workspace8 "8:term"
      set $workspace9 "9:term"
      set $workspace0 "10:term"
    '';
    # special bindsyms are unsupported by this module
    extraConfig = ''
      bindsym --whole-window Mod4+button2 kill

      bindsym --locked XF86AudioMute exec ${pkgs.avizo}/bin/volumectl -M0 toggle-mute && pkill -SIGRTMIN+4 waybar
      bindsym --locked XF86AudioRaiseVolume exec ${pkgs.avizo}/bin/volumectl -M0 up 1 && pkill -SIGRTMIN+4 waybar
      bindsym --locked XF86AudioLowerVolume exec ${pkgs.avizo}/bin/volumectl -M0 down 1 && pkill -SIGRTMIN+4 waybar
      bindsym --locked Shift+XF86AudioRaiseVolume exec ${pkgs.avizo}/bin/volumectl -M0 up 5 && pkill -SIGRTMIN+4 waybar
      bindsym --locked Shift+XF86AudioLowerVolume exec ${pkgs.avizo}/bin/volumectl -M0 down 5 && pkill -SIGRTMIN+4 waybar

      bindsym --locked XF86AudioPlay exec ${pkgs.playerctl}/bin/playerctl -p spotify play-pause
      bindsym --locked XF86AudioNext exec ${pkgs.playerctl}/bin/playerctl -p spotify next
      bindsym --locked XF86AudioPrev exec ${pkgs.playerctl}/bin/playerctl -p spotify previous
    '';
    config = {
      modifier = "Mod4";
      terminal = "kitty";
      workspaceAutoBackAndForth = true;
      fonts = {
        names = ["Fira Mono"];
        size = 11.0;
      };
      gaps = {
        smartBorders = "on";
      };
      window = {
        border = 1;
        commands = [
          {
            command = "title_format 'ಠ_ಠ :: %title'";
            criteria = {
              shell = "xwayland";
            };
          }
          {
            command = "inhibit_idle fullscreen";
            criteria = {
              app_id = "firefox";
            };
          }
          {
            command = "inhibit_idle visible";
            criteria = {
              app_id = "vlc";
            };
          }
          {
            command = "move scratchpad; sticky enable";
            criteria = {
              title = "^scratch:";
            };
          }
        ];
      };
      focus = {
        wrapping = "yes";
      };
      input = {
        "type:keyboard" = {
          xkb_layout = "us";
          xkb_model = "pc105";
          xkb_variant = "altgr-intl";
          xkb_options = "compose:rctrl,lv3:caps_switch";
        };
        "2:10:TPPS/2_Elan_TrackPoint" = {
          accel_profile = "adaptive";
          pointer_accel = "0.6";
          calibration_matrix = "8 0 0 0 5 0";
        };
        "type:touchpad" = {
          # events = "disabled";
          tap = "enabled";
          dwt = "enabled";
          middle_emulation = "enabled";
        };
      };
      output = {
        "*" = {
          bg = "#${config.colors.dark_bg} solid_color";
        };
      };
      bars = [];
      colors = {
        background = "#${config.colors.background}";
        focused = {
          border = "#${config.colors.blue}";
          background = "#${config.colors.blue}";
          text = "#${config.colors.background}";
          indicator = "#${config.colors.red}";
          childBorder = "#${config.colors.blue}";
        };
        focusedInactive = {
          border = "#${config.colors.light_bg}";
          background = "#${config.colors.light_bg}";
          text = "#${config.colors.foreground}";
          indicator = "#${config.colors.light_bg}";
          childBorder = "#${config.colors.light_bg}";
        };
        unfocused = {
          border = "#${config.colors.light_bg}";
          background = "#${config.colors.light_bg}";
          text = "#${config.colors.foreground}";
          indicator = "#${config.colors.light_bg}";
          childBorder = "#${config.colors.light_bg}";
        };
        urgent = {
          border = "#${config.colors.red}";
          background = "#${config.colors.red}";
          text = "#${config.colors.background}";
          indicator = "#${config.colors.red}";
          childBorder = "#${config.colors.red}";
        };
      };
      modes = {
        "suspend" = {
          "Ctrl+Mod4+Backslash" = "exec systemctl suspend; mode 'default'";
          "q" = "mode 'default'";
          "Return" = "mode 'default'";
          "Escape" = "mode 'default'";
        };
        "close" = {
          "c" = "kill; mode 'default'";
          "q" = "mode 'default'";
          "Return" = "mode 'default'";
          "Escape" = "mode 'default'";
        };
        "resize" = {
          "h" = "resize shrink horizontal 50 px";
          "j" = "resize shrink vertical 50 px";
          "k" = "resize grow vertical 50 px";
          "l" = "resize grow horizontal 50 px";
          "XF86AudioRaiseVolume" = "resize grow horizontal 20 px";
          "XF86AudioLowerVolume" = "resize shrink horizontal 20 px";
          "Shift+XF86AudioRaiseVolume" = "resize grow vertical 20 px";
          "Shift+XF86AudioLowerVolume" = "resize shrink vertical 20 px";
          "Shift+h" = "resize shrink horizontal 20 px";
          "Shift+j" = "resize shrink vertical 20 px";
          "Shift+k" = "resize grow vertical 20 px";
          "Shift+l" = "resize grow horizontal 20 px";
          "Control+Shift+h" = "resize shrink horizontal 1 px";
          "Control+Shift+j" = "resize shrink vertical 1 px";
          "Control+Shift+k" = "resize grow vertical 1 px";
          "Control+Shift+l" = "resize grow horizontal 1 px";
          "q" = "mode 'default'";
          "Return" = "mode 'default'";
          "Escape" = "mode 'default'";
        };
        "move" = {
          "h" = "move left";
          "j" = "move down";
          "k" = "move up";
          "l" = "move right";
          "XF86AudioRaiseVolume" = "move right";
          "XF86AudioLowerVolume" = "move left";
          "Shift+XF86AudioRaiseVolume" = "move up";
          "Shift+XF86AudioLowerVolume" = "move down";
          "q" = "mode 'default'";
          "Return" = "mode 'default'";
          "Escape" = "mode 'default'";
        };
        "escape" = {
          "Mod4+Escape" = "mode 'default'";
        };
        "exit" = {
          "Mod4+Shift+e" = "exit";
          "y" = "exit";
          "n" = "mode 'default'";
          "q" = "mode 'default'";
          "Return" = "mode 'default'";
          "Escape" = "mode 'default'";
        };
      };
      startup = [
        {command = "${pkgs.clipman}/bin/clipman clear --all";}
      ];
      keybindings = {
        # scratch
        "Mod4+Tab" = "scratchpad show";
        "Mod4+Shift+Tab" = "move scratchpad";

        # virtual output for presenting
        "Mod4+Backspace" = "output eDP-1 enable";
        "Mod4+Shift+Backspace" = "output eDP-1 disable";

        # run
        "Mod4+Return" = "exec kitty";
        "XF86Display" = "exec ${pkgs.wdisplays}/bin/wdisplays";

        # lock
        "Mod4+Backslash" = "exec ${pkgs.swaylock-effects}/bin/swaylock -f";
        "Cancel" = "exec ${pkgs.swaylock-effects}/bin/swaylock -f";

        # launcher
        "Mod4+d" = "exec ${pkgs.wofi}/bin/wofi -G -p '' -S run";
        "Mod4+Ctrl+v" = "exec ${pkgs.clipman}/bin/clipman pick -t wofi";

        # notifications
        "Mod4+n" = "exec ${pkgs.mako}/bin/makoctl dismiss";
        "Mod4+Shift+n" = "exec ${pkgs.mako}/bin/makoctl dismiss -a";

        # screenshots
        "Print" = ''exec ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" "/home/danieln/pictures/screenshot-area-$(date +%d-%m-%Y-%T).png"'';
        "Mod4+Shift+s" = ''exec ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" "/home/danieln/pictures/screenshot-area-$(date +%d-%m-%Y-%T).png"''; # laptop screenshot key
        "Shift+Print" = ''exec ${pkgs.grim}/bin/grim "/home/danieln/pictures/screenshot-full-$(date +%d-%m-%Y-%T).png"'';

        # sway control
        "Mod4+Shift+c" = "reload";
        "Mod4+Shift+e" = "mode 'exit'";
        "Mod4+c" = "mode 'close'";
        "Mod4+Ctrl+Backslash" = "mode 'suspend'";
        "Mod4+Period" = "exec ${pkgs.psmisc}/bin/killall -SIGUSR1 .waybar-wrapped";
        "Mod4+Escape" = "mode 'escape'";
        "Mod4+w" = "layout tabbed";
        "Mod4+a" = "layout toggle split";

        # windows
        "Mod4+comma" = "border toggle";
        "Mod4+f" = "fullscreen toggle";
        "Mod4+p" = "sticky toggle";
        "Mod4+s" = "split toggle";
        "Mod4+x" = "split none";
        "Mod4+v" = "floating toggle";

        # resize
        "Mod4+r" = "mode 'resize'";
        "Mod4+XF86AudioRaiseVolume" = "resize grow horizontal 20 px";
        "Mod4+XF86AudioLowerVolume" = "resize shrink horizontal 20 px";
        "Mod4+Shift+XF86AudioRaiseVolume" = "resize grow vertical 20 px";
        "Mod4+Shift+XF86AudioLowerVolume" = "resize shrink vertical 20 px";
        "Mod4+Shift+r" = "resize set width 35 ppt; split v";

        # focus
        "Mod4+space" = "focus mode_toggle";
        "Mod4+o" = "focus parent";
        "Mod4+i" = "focus child";
        "Mod4+h" = "focus left";
        "Mod4+j" = "focus down";
        "Mod4+k" = "focus up";
        "Mod4+l" = "focus right";

        # move
        "Mod4+m" = "mode 'move'";
        "Mod4+Shift+h" = "move left";
        "Mod4+Shift+j" = "move down";
        "Mod4+Shift+k" = "move up";
        "Mod4+Shift+l" = "move right";

        # workspaces
        "Ctrl+Mod4+j" = "workspace prev_on_output";
        "Ctrl+Mod4+k" = "workspace next_on_output";
        "Ctrl+Shift+Mod4+h" = "move workspace to output left; move workspace to output up";
        "Ctrl+Shift+Mod4+l" = "move workspace to output right; move workspace to output down";
        "Mod4+1" = "workspace $workspace1";
        "Mod4+2" = "workspace $workspace2";
        "Mod4+3" = "workspace $workspace3";
        "Mod4+4" = "workspace $workspace4";
        "Mod4+5" = "workspace $workspace5";
        "Mod4+6" = "workspace $workspace6";
        "Mod4+7" = "workspace $workspace7";
        "Mod4+8" = "workspace $workspace8";
        "Mod4+9" = "workspace $workspace9";
        "Mod4+0" = "workspace $workspace0";
        "Mod4+Shift+1" = "move container to workspace $workspace1";
        "Mod4+Shift+2" = "move container to workspace $workspace2";
        "Mod4+Shift+3" = "move container to workspace $workspace3";
        "Mod4+Shift+4" = "move container to workspace $workspace4";
        "Mod4+Shift+5" = "move container to workspace $workspace5";
        "Mod4+Shift+6" = "move container to workspace $workspace6";
        "Mod4+Shift+7" = "move container to workspace $workspace7";
        "Mod4+Shift+8" = "move container to workspace $workspace8";
        "Mod4+Shift+9" = "move container to workspace $workspace9";
        "Mod4+Shift+0" = "move container to workspace $workspace0";

        # TODO: build DND binding and indicator for waybar?
        # fancy keys
        "XF86AudioMicMute" = "exec ${pkgs.avizo}/bin/volumectl -M0 -m toggle-mute && pkill -SIGRTMIN+4 waybar";
        "XF86AudioStop" = "exec ${pkgs.playerctl}/bin/playerctl -p spotify stop";

        # brightness
        "XF86MonBrightnessUp" = "exec ${pkgs.avizo}/bin/lightctl -M0 up 5";
        "XF86MonBrightnessDown" = "exec ${pkgs.avizo}/bin/lightctl -M0 down 5";
        "Shift+XF86MonBrightnessUp" = "exec ${pkgs.sudo}/bin/sudo ${pkgs.ddcutil}/bin/ddcutil -d 1 setvcp 10 + 20";
        "Shift+XF86MonBrightnessDown" = "exec ${pkgs.sudo}/bin/sudo ${pkgs.ddcutil}/bin/ddcutil -d 1 setvcp 10 - 20";

        # peripheral control
        "XF86TouchpadToggle" = "input type:touchpad events toggle enabled disabled";
      };
      assigns = {
        "$workspace2" = [
          {
            instance = "slack";
          }
        ];
      };
    };
  };
}
