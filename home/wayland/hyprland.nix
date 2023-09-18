{ config, ... }:

{
  # TODO: figure out how to focus from floating windows to tiled windows
  # TODO: exec ${pkgs.clipman}/bin/clipman clear --all on startup
  # TODO: make "Mod4+Ctrl+v" = "exec ${pkgs.clipman}/bin/clipman pick -t wofi"; or similar
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = [
        "eDP-1,1920x1080@60,0x0,1"
      ];
      misc = {
        disable_autoreload = true;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        background_color = "rgb(${config.colors.dark_bg})";
        groupbar_gradients = false;
        render_titles_in_groupbar = false;
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
      general = {
        layout = "master";
        gaps_in = 3;
        gaps_out = 2;
        border_size = 2;
        "col.active_border" = "rgb(${config.colors.blue}) rgb(${config.colors.light_bg}) 50deg";
        "col.group_border_active" = "rgb(${config.colors.blue}) rgb(${config.colors.light_bg}) 50deg";
        "col.inactive_border" = "rgb(${config.colors.light_bg}) rgb(${config.colors.background}) 50deg";
        "col.group_border" = "rgb(${config.colors.light_bg}) rgb(${config.colors.background}) 50deg";
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
        enabled = true;
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
        orientation = "center";
        mfact = 0.7;
      };
      bind = [
        # launch stuff
        "SUPER, return, exec, kitty"
        "SUPER, backslash, exec, swaylock"
        "SUPER, d, exec, wofi -G -p '' -S run,"
        "SUPER, n, exec, makoctl dismiss"
        "SUPER_SHIFT, n, exec, makoctl dismiss -a"
        ", Print, exec, fish -c \"grim -g (slurp)\""
        "SHIFT, Print, exec, grim"
        ", XF86Display, exec, wdisplays"

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

        "SUPER, f, fullscreen,0"
        "SUPER_SHIFT, f, fullscreen,1"
        "SUPER_CTRL, f, fakefullscreen,"

        "SUPER, XF86AudioRaiseVolume, resizeactive, 20 0"
        "SUPER, XF86AudioLowerVolume, resizeactive, -20 0"

        "SUPER, w, togglegroup,"
        "SUPER_SHIFT, w, lockactivegroup, toggle"
        "SUPER, tab, changegroupactive, f"
        "SUPER_SHIFT, tab, changegroupactive, b"

        # window focus
        "SUPER, tab, cyclenext," # useful for getting to floats
        "SUPER, tab, bringactivetotop"
        "SUPER_SHIFT, tab, cyclenext, prev"
        "SUPER, h, movefocus, l"
        "SUPER, l, movefocus, r"
        "SUPER, k, movefocus, u"
        "SUPER, j, movefocus, d"

        # window moving
        "SUPER_SHIFT, h, moveintogroup, l"
        "SUPER_SHIFT, h, movewindow, l"
        "SUPER_SHIFT, l, moveintogroup, r"
        "SUPER_SHIFT, l, movewindow, r"
        "SUPER_SHIFT, k, moveintogroup, u"
        "SUPER_SHIFT, k, movewindow, u"
        "SUPER_SHIFT, j, moveintogroup, d"
        "SUPER_SHIFT, j, movewindow, d"

        # workspace focus
        "SUPER, mouse_down, workspace, e-1"
        "SUPER, mouse_up, workspace, e+1"
        "CTRL_SUPER, j, workspace, e-1"
        "CTRL_SUPER, k, workspace, e+1"
        "CTRL_SUPER, XF86AudioLowerVolume, workspace, e-1"
        "CTRL_SUPER, XF86AudioRaiseVolume, workspace, e+1"

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

        ", XF86AudioPlay, exec, playerctl -p spotify play-pause"
        ", XF86AudioNext, exec, playerctl -p spotify next"
        ", XF86AudioPrev, exec, playerctl -p spotify previous"
      ];
      windowrulev2 = [
        "float, title:^(Firefox — Sharing Indicator)$"
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
}
