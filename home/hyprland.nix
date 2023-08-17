{ pkgs, inputs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1

      misc {
        disable_autoreload = true
        disable_hyprland_logo = true
        disable_splash_rendering = true
      }

      input {
        kb_layout = us
        kb_variant = altgr-intl
        kb_model = pc105
        kb_options = compose:rctrl,lv3:caps_switch
        kb_rules =
        follow_mouse = 1
        touchpad {
          natural_scroll = false
          scroll_factor = 0.3
        }
        sensitivity = 0
      }

      general {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more
        layout = dwindle
        gaps_in = 0
        gaps_out = 0
      }

      decoration {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more
        drop_shadow = false
        dim_inactive = true
      }

      animations {
        enabled = false
      }

      dwindle {
        preserve_split = true
      }

      master {
        new_is_master = false
      }

      $mod = SUPER

      # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
      bind = $mod, return, exec, ${pkgs.kitty}/bin/kitty
      bind = $mod, c, killactive,
      bind = $mod, v, togglefloating,
      #bind = $mod, d, exec, wofi --show drun
      bind = $mod, p, pseudo, # dwindle
      bind = $mod, a, togglesplit, # dwindle

      bind = $mod, h, movefocus, l
      bind = $mod, l, movefocus, r
      bind = $mod, k, movefocus, u
      bind = $mod, j, movefocus, d

      bind = $mod, mouse_down, workspace, e+1
      bind = $mod, mouse_up, workspace, e-1

      bindm = $mod, mouse:272, movewindow
      bindm = $mod, mouse:273, resizewindow

      # workspaces
      # binds mod + [shift +] {1..10} to [move to] ws {1..10}
      ${builtins.concatStringsSep "\n" (builtins.genList (
          x: let
            ws = let
              c = (x + 1) / 10;
            in
              builtins.toString (x + 1 - (c * 10));
          in ''
            bind = $mod, ${ws}, workspace, ${toString (x + 1)}
            bind = $mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}
          ''
        )
        10)}
    '';
  };
}
