{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = [
        ",preferred,auto,1"
      ];
      misc = {
        disable_autoreload = true;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        background_color = "rgb(${config.colors.dark_bg})";
      };
      input = {
        kb_layout = "us";
        kb_variant = "altgr-intl";
        kb_model = "pc105";
        kb_options = "compose:rctrl,lv3:caps_switch";
        follow_mouse = 1;
        mouse_refocus = false;
        touchpad = {
          natural_scroll = false;
          scroll_factor = 0.3;
        };
        sensitivity = 0;
      };
      device = [
        {
          name = "syna8007:00-06cb:cd8c-touchpad";
          enabled = false;
        }
        {
          name = "tpps/2-elan-trackpoint";
          sensitivity = "+0.5";
        }
      ];
      general = {
        layout = "master";
        gaps_in = 3;
        gaps_out = 2;
        border_size = 2;
        "col.active_border" = "rgb(${config.colors.blue}) rgb(${config.colors.light_bg}) 50deg";
        "col.inactive_border" = "rgb(${config.colors.light_bg}) rgb(${config.colors.background}) 50deg";
        cursor_inactive_timeout = 3;
        no_cursor_warps = true;
        no_focus_fallback = true;
      };
      decoration = {
        drop_shadow = false;
        shadow_range = 5;
        shadow_render_power = 2;
        "col.shadow" = "rgb(${config.colors.blue})";
        "col.shadow_inactive" = "rgba(00000000)";
        rounding = 3;
        dim_inactive = false;
        blur = {
          enabled = false;
        };
      };
      animations = {
        enabled = false;
      };
      animation = {
        bezier = [
        ];
        animation = [
          "fade, 0, 1, default"
          "border, 0, 1, default"
          "borderangle, 0, 1, default"
        ];
      };
      dwindle = {
        preserve_split = true;
        force_split = 2;
      };
      master = {
        new_is_master = false;
        orientation = "right";
        mfact = 0.7;
      };
      bind = [
        # launch stuff
        "SUPER, return, exec, kitty"
        "SUPER, backslash, exec, swaylock"
        "SUPER, d, exec, wofi -G -p '' -S run,"
        "SUPER_CTRL, v, exec, ${pkgs.clipman}/bin/clipman pick -t wofi"
        "SUPER, n, exec, makoctl dismiss"
        "SUPER_SHIFT, n, exec, makoctl dismiss -a"
        ", Print, exec, fish -c \"grim -g (slurp)\""
        "SHIFT, Print, exec, grim"
        ", XF86Display, exec, wdisplays"
        ", XF86Messenger, exec, makoctl dismiss"
        ", XF86Go, exec, wofi -G -p '' -S run,"
        ", Cancel, exec, swaylock"
        ", XF86Favorites, fullscreen,0"

        # layout change
        "SUPER, m, exec, hyprctl keyword general:layout 'master'"
        "SUPER_SHIFT, m, exec, hyprctl keyword general:layout 'dwindle'"

        # dwindle layout
        "SUPER, a, togglesplit,"

        # master layout
        "SUPER, bracketright, layoutmsg, addmaster"
        "SUPER, bracketleft, layoutmsg, removemaster"
        "SUPER, left, layoutmsg, orientationleft"
        "SUPER, right, layoutmsg, orientationright"
        "SUPER, down, layoutmsg, orientationbottom"
        "SUPER, up, layoutmsg, orientationtop"
        "SUPER, home, layoutmsg, orientationcenter"

        # wm operations
        "SUPER, backspace, killactive,"

        "SUPER, minus, movetoworkspace, special"
        "SUPER_SHIFT, minus, movetoworkspace, +0" # unspecial at current workspace
        "SUPER, space, togglespecialworkspace,"

        "SUPER, v, togglefloating,"
        "SUPER, q, pin,"
        "SUPER, p, pin,"

        "SUPER, f, fullscreen,1"
        "SUPER_SHIFT, f, fullscreen,0"
        "SUPER_CTRL, f, fakefullscreen,"


        # resizing
        "SUPER, XF86AudioRaiseVolume, resizeactive, 20 0"
        "SUPER, XF86AudioLowerVolume, resizeactive, -20 0"
        "SUPER_SHIFT, XF86AudioRaiseVolume, resizeactive, 0 20"
        "SUPER_SHIFT, XF86AudioLowerVolume, resizeactive, 0 -20"

        # window focus
        "SUPER, tab, cyclenext, tiled"
        "SUPER, tab, bringactivetotop"
        "SUPER_SHIFT, tab, cyclenext, floating"
        "SUPER, h, movefocus, l"
        "SUPER, l, movefocus, r"
        "SUPER, k, movefocus, u"
        "SUPER, j, movefocus, d"

        # window moving
        "SUPER_SHIFT, h, movewindow, l"
        "SUPER_SHIFT, l, movewindow, r"
        "SUPER_SHIFT, k, movewindow, u"
        "SUPER_SHIFT, j, movewindow, d"

        # workspace focus
        "CTRL_SUPER, j, workspace, m-1"
        "CTRL_SUPER, k, workspace, m+1"

        "SUPER, 1, workspace, 1"
        "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3"
        "SUPER, 4, workspace, 4"
        "SUPER, 5, workspace, 5"
        "SUPER, 6, workspace, 6"
        "SUPER, 7, workspace, 7"
        "SUPER, 8, workspace, 8"
        "SUPER, 9, workspace, 9"
        "SUPER, 0, workspace, 10"

        # workspace moving
        "CTRL_SUPER, h, movecurrentworkspacetomonitor, -1"
        "CTRL_SUPER, l, movecurrentworkspacetomonitor, +1"

        "SUPER_CTRL, 1, movetoworkspace, 1"
        "SUPER_CTRL, 2, movetoworkspace, 2"
        "SUPER_CTRL, 3, movetoworkspace, 3"
        "SUPER_CTRL, 4, movetoworkspace, 4"
        "SUPER_CTRL, 5, movetoworkspace, 5"
        "SUPER_CTRL, 6, movetoworkspace, 6"
        "SUPER_CTRL, 7, movetoworkspace, 7"
        "SUPER_CTRL, 8, movetoworkspace, 8"
        "SUPER_CTRL, 9, movetoworkspace, 9"
        "SUPER_CTRL, 0, movetoworkspace, 10"

        "SUPER_SHIFT, 1, movetoworkspacesilent, 1"
        "SUPER_SHIFT, 2, movetoworkspacesilent, 2"
        "SUPER_SHIFT, 3, movetoworkspacesilent, 3"
        "SUPER_SHIFT, 4, movetoworkspacesilent, 4"
        "SUPER_SHIFT, 5, movetoworkspacesilent, 5"
        "SUPER_SHIFT, 6, movetoworkspacesilent, 6"
        "SUPER_SHIFT, 7, movetoworkspacesilent, 7"
        "SUPER_SHIFT, 8, movetoworkspacesilent, 8"
        "SUPER_SHIFT, 9, movetoworkspacesilent, 9"
        "SUPER_SHIFT, 0, movetoworkspacesilent, 10"
      ];
      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];
      bindl = [
        # lock screen binds
        ", XF86MonBrightnessUp, exec, lightctl up 5"
        ", XF86MonBrightnessDown, exec, lightctl down 5"
        "SHIFT, XF86MonBrightnessUp, exec, sudo ddcutil -d 1 setvcp 10 + 20"
        "SHIFT, XF86MonBrightnessDown, exec, sudo ddcutil -d 1 setvcp 10 - 20"

        ", XF86AudioMicMute, exec, volumectl -m toggle-mute && pkill -SIGRTMIN+4 waybar"
        ", XF86AudioMute, exec, volumectl toggle-mute && pkill -SIGRTMIN+4 waybar"
        ", XF86AudioRaiseVolume, exec, volumectl up 1 && pkill -SIGRTMIN+4 waybar"
        ", XF86AudioLowerVolume, exec, volumectl down 1 && pkill -SIGRTMIN+4 waybar"
        "SHIFT, XF86AudioRaiseVolume, exec, volumectl up 5 && pkill -SIGRTMIN+4 waybar"
        "SHIFT, XF86AudioLowerVolume, exec, volumectl down 5 && pkill -SIGRTMIN+4 waybar"
        "CTRL, XF86AudioRaiseVolume, exec, sudo ddcutil -d 1 setvcp 10 + 20"
        "CTRL, XF86AudioLowerVolume, exec, sudo ddcutil -d 1 setvcp 10 - 20"

        ", XF86AudioPlay, exec, playerctl -p spotify play-pause"
        ", XF86AudioNext, exec, playerctl -p spotify next"
        ", XF86AudioPrev, exec, playerctl -p spotify previous"
      ];
      workspace = [
        "special, gapsout:40, gapsin:10"
      ];
      windowrulev2 = [
        "float, title:^(Firefox — Sharing Indicator)$"
        "float, title:^(Picture-in-Picture)$"
      ];
    };
    extraConfig = ''
      env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
      bind=SUPER,c,submap,close
      submap=close
      bind=SUPER,c,killactive
      bind=,c,killactive
      bind=SUPER,c,submap,reset
      bind=,c,submap,reset
      bind=,q,submap,reset
      bind=,escape,submap,reset
      submap=reset

      bind=CTRL_SUPER,backslash,submap,suspend
      submap=suspend
      bind=CTRL_SUPER,backslash,exec,systemctl suspend
      bind=CTRL_SUPER,backslash,submap,reset
      bind=,backslash,exec,systemctl suspend
      bind=,backslash,submap,reset
      bind=,q,submap,reset
      bind=,escape,submap,reset
      submap=reset

      bind=SUPER,escape,submap,escape
      submap=escape
      bind=,escape,submap,reset
      submap=reset
    '';
  };

  wayland.windowManager.sway = {
    enable = true;
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

      bindsym --locked XF86AudioMute exec ${pkgs.avizo}/bin/volumectl toggle-mute && pkill -SIGRTMIN+4 waybar
      bindsym --locked XF86AudioRaiseVolume exec ${pkgs.avizo}/bin/volumectl up 1 && pkill -SIGRTMIN+4 waybar
      bindsym --locked XF86AudioLowerVolume exec ${pkgs.avizo}/bin/volumectl down 1 && pkill -SIGRTMIN+4 waybar
      bindsym --locked Shift+XF86AudioRaiseVolume exec ${pkgs.avizo}/bin/volumectl up 5 && pkill -SIGRTMIN+4 waybar
      bindsym --locked Shift+XF86AudioLowerVolume exec ${pkgs.avizo}/bin/volumectl down 5 && pkill -SIGRTMIN+4 waybar

      bindsym --locked XF86AudioPlay exec ${pkgs.playerctl}/bin/playerctl -p spotify play-pause
      bindsym --locked XF86AudioNext exec ${pkgs.playerctl}/bin/playerctl -p spotify next
      bindsym --locked XF86AudioPrev exec ${pkgs.playerctl}/bin/playerctl -p spotify previous
    '';
    config = {
      modifier = "Mod4";
      terminal = "${pkgs.kitty}/bin/kitty";
      workspaceAutoBackAndForth = true;
      fonts = {
        names = [ "Fira Mono" ];
        size = 11.0;
      };
      gaps = {
        smartBorders = "on";
      };
      window = {
        border = 2;
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
          events = "disabled";
          tap = "enabled";
          dwt = "enabled";
          middle_emulation = "enabled";
        };
      };
      output = {
        "*" = {
          bg = "#${config.colors.dark_bg} solid_color";
        };
        "HEADLESS-1" = {
          position = "0 1440";
          resolution = "1000 1400";
          bg = "#${config.colors.red} solid_color";
        };
      };
      bars = [ ];
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
          border = "#${config.colors.background}";
          background = "#${config.colors.background}";
          text = "#${config.colors.foreground}";
          indicator = "#${config.colors.background}";
          childBorder = "#${config.colors.background}";
        };
        unfocused = {
          border = "#${config.colors.background}";
          background = "#${config.colors.background}";
          text = "#${config.colors.foreground}";
          indicator = "#${config.colors.background}";
          childBorder = "#${config.colors.background}";
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
          "q" = "mode 'default'";
          "Return" = "mode 'default'";
          "Escape" = "mode 'default'";
        };
        "escape" = {
          "Escape" = "mode 'default'";
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
        { command = "${pkgs.clipman}/bin/clipman clear --all"; }
        { command = "${pkgs.kitty}/bin/kitty -T 'scratch: ipython' ${pkgs.fish}/bin/fish -c 'while true; ${pkgs.python3Packages.ipython}/bin/ipython; end'"; }
        { command = "swaymsg create_output && swaymsg output HEADLESS-1 disable"; }
      ];
      keybindings = {
        # scratch
        "XF86Favorites" = "[title='scratch: ipython'] scratchpad show";
        "F5" = "[title='scratch: ipython'] scratchpad show";
        "Mod4+Backspace" = "scratchpad show";
        "Mod4+Minus" = "move scratchpad";
        "Mod4+Equal" = "move scratchpad";

        # run
        "Mod4+Return" = "exec ${pkgs.kitty}/bin/kitty";
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
        "Print" = "exec ${pkgs.grim}/bin/grim -g $(${pkgs.slurp}/bin/slurp)";
        "Shift+Print" = "exec ${pkgs.grim}/bin/grim";

        # sway control
        "Mod4+Shift+c" = "reload";
        "Mod4+Shift+e" = "mode 'exit'";
        "Mod4+c" = "mode 'close'";
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
        "XF86AudioMicMute" = "exec ${pkgs.avizo}/bin/volumectl -m toggle-mute && pkill -SIGRTMIN+4 waybar";
        "XF86AudioStop" = "exec ${pkgs.playerctl}/bin/playerctl -p spotify stop";

        # brightness
        "XF86MonBrightnessUp" = "exec ${pkgs.avizo}/bin/lightctl up 5";
        "XF86MonBrightnessDown" = "exec ${pkgs.avizo}/bin/lightctl down 5";
        "Shift+XF86MonBrightnessUp" = "exec ${pkgs.sudo}/bin/sudo ${pkgs.ddcutil}/bin/ddcutil -d 1 setvcp 10 + 20";
        "Shift+XF86MonBrightnessDown" = "exec ${pkgs.sudo}/bin/sudo ${pkgs.ddcutil}/bin/ddcutil -d 1 setvcp 10 - 20";

        # peripheral control
        "XF86Messenger" = "input type:touchpad events toggle enabled disabled";
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
