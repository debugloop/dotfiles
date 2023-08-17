{ pkgs, config, lib, ... }:

{
  imports = [
    ./avizo.nix
    ./clipman.nix
    ./kanshi.nix
    ./mako.nix
    ./swayidle.nix
    ./swaylock.nix
    ./waybar.nix
  ];

  home.packages = with pkgs; [
    wev
    grim
    slurp
    playerctl
    wdisplays
    wofi
  ];

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
    extraConfig = lib.mkDefault ''
      bindsym --whole-window Mod4+button2 kill

      bindsym --locked XF86AudioRaiseVolume exec ${pkgs.avizo}/bin/volumectl up 1 && pkill -SIGRTMIN+4 waybar
      bindsym --locked XF86AudioLowerVolume exec ${pkgs.avizo}/bin/volumectl down 1 && pkill -SIGRTMIN+4 waybar
      bindsym --locked Shift+XF86AudioRaiseVolume exec ${pkgs.avizo}/bin/volumectl up 5 && pkill -SIGRTMIN+4 waybar
      bindsym --locked Shift+XF86AudioLowerVolume exec ${pkgs.avizo}/bin/volumectl down 5 && pkill -SIGRTMIN+4 waybar
      bindsym --locked XF86AudioMute exec ${pkgs.avizo}/bin/volumectl toggle-mute && pkill -SIGRTMIN+4 waybar
      bindsym --locked XF86AudioPlay exec ${pkgs.playerctl}/bin/playerctl -p spotify play-pause
      bindsym --locked XF86AudioNext exec ${pkgs.playerctl}/bin/playerctl -p spotify next
      bindsym --locked XF86AudioPrev exec ${pkgs.playerctl}/bin/playerctl -p spotify previous
    '';
    config = {
      modifier = "Mod4";
      workspaceAutoBackAndForth = true;
      fonts = {
        names = [ "Fira Mono" ];
        size = 11.0;
      };
      window = {
        hideEdgeBorders = "both";
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
            command = "floating enable; resize set 30px; border none; move position 66ppt -25px";
            criteria = {
              app_id = "firefox";
              title = "Firefox — Sharing Indicator";
            };
          }
          {
            command = "inhibit_idle visible";
            criteria = {
              app_id = "vlc";
            };
          }
          {
            command = "border pixel 1";
            criteria = {
              app_id = "gcr-prompter";
            };
          }
          {
            command = "floating enable; sticky enable";
            criteria = {
              app_id = "thunderbird";
              title = "^.* Reminder$";
            };
          }
          {
            command = "move scratchpad; sticky enable";
            criteria = {
              title = "^scratch:";
            };
          }
          {
            command = "floating enable";
            criteria = {
              title = "^float:";
            };
          }
        ];
      };
      focus = {
        wrapping = "yes";
      };
      /* seat = { */
      /*   "*" = { */
      /*     hide_cursor = "when-typing enable"; */
      /*   }; */
      /* }; */
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
      };
      bars = [ ];
      colors = {
        background = "#${config.colors.background}";
        placeholder = {
          border = "#${config.colors.background}";
          background = "#${config.colors.dark_bg}";
          text = "#${config.colors.light_bg}";
          indicator = "#${config.colors.background}";
          childBorder = "#${config.colors.background}";
        };
        focused = {
          border = "#${config.colors.blue}";
          background = "#${config.colors.blue}";
          text = "#${config.colors.background}";
          indicator = "#${config.colors.red}";
          childBorder = "#${config.colors.blue}";
        };
        focusedInactive = {
          border = "#${config.colors.cyan}";
          background = "#${config.colors.cyan}";
          text = "#${config.colors.background}";
          indicator = "#${config.colors.cyan}";
          childBorder = "#${config.colors.cyan}";
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
          indicator = "#${config.colors.background}";
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
        "launch" = {
          "f" = "exec ${pkgs.firefox}/bin/firefox; mode 'default'";
          "t" = "exec ${pkgs.thunderbird}/bin/thunderbird; mode 'default'";
          "n" = "exec ${pkgs.cinnamon.nemo}/bin/nemo; mode 'default'";
          "s" = "exec ${pkgs.spotify}/bin/spotify; mode 'default'";
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
        { command = "${pkgs.clipman}/bin/clipman clear --all"; always = true; }
        { command = "${pkgs.kitty}/bin/kitty -T 'scratch: ipython' ${pkgs.fish}/bin/fish -c 'while true; ${pkgs.python3Packages.ipython}/bin/ipython; end'"; }
      ];
      keybindings = {
        # launching and scratch
        "XF86Favorites" = "[title='scratch: ipython'] scratchpad show";
        "Pause" = "[title='scratch: ipython'] scratchpad show";
        "Mod4+d" = "exec ${pkgs.wofi}/bin/wofi -G -t kitty -S run";
        "Mod4+Ctrl+v" = "exec ${pkgs.clipman}/bin/clipman pick -t wofi";
        # sway control
        "Mod4+Shift+c" = "reload";
        "Mod4+Shift+e" = "mode 'exit'";
        "Mod4+period" = "exec ${pkgs.psmisc}/bin/killall -SIGUSR1 waybar";
        "Mod4+Backslash" = "exec ${pkgs.swaylock-effects}/bin/swaylock -f";
        "Mod4+Escape" = "mode 'escape'";
        "Mod4+XF86AudioRaiseVolume" = "resize grow horizontal 20 px";
        "Mod4+XF86AudioLowerVolume" = "resize shrink horizontal 20 px";
        # container operations
        "Mod4+c" = "mode 'close'";
        "Mod4+m" = "mode 'move'";
        "Mod4+r" = "mode 'resize'";
        "Mod4+comma" = "border toggle";
        "Mod4+q" = "sticky toggle";
        "Mod4+f" = "fullscreen";
        "Mod4+Shift+f" = "fullscreen global";
        "Mod4+Shift+space" = "floating toggle";
        "Mod4+space" = "focus mode_toggle";
        # container movement
        "Mod4+o" = "focus parent";
        "Mod4+i" = "focus child";
        "Mod4+h" = "focus left";
        "Mod4+j" = "focus down";
        "Mod4+k" = "focus up";
        "Mod4+l" = "focus right";
        "Mod4+Shift+h" = "move left";
        "Mod4+Shift+j" = "move down";
        "Mod4+Shift+k" = "move up";
        "Mod4+Shift+l" = "move right";
        # split this container
        "Mod4+b" = "splith";
        "Mod4+v" = "splitv";
        # container layouts
        "Mod4+s" = "layout stacking";
        "Mod4+w" = "layout tabbed";
        "Mod4+e" = "layout toggle split";
        "Mod4+a" = "layout toggle split"; # default is e, but I'm used to this
        # workspace movement
        "Ctrl+Mod4+j" = "workspace prev_on_output";
        "Ctrl+Mod4+k" = "workspace next_on_output";
        "Ctrl+Shift+Mod4+h" = "move workspace to output left";
        "Ctrl+Shift+Mod4+j" = "move workspace to output down";
        "Ctrl+Shift+Mod4+k" = "move workspace to output up";
        "Ctrl+Shift+Mod4+l" = "move workspace to output right";
        # workspace direct addressing
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
        # launch stuff
        "Mod4+p" = "mode 'launch'";
        "Mod4+Return" = "exec ${pkgs.kitty}/bin/kitty";
        "Mod4+n" = "exec ${pkgs.mako}/bin/makoctl dismiss";
        "Mod4+Shift+n" = "exec ${pkgs.mako}/bin/makoctl dismiss -a";
        # TODO: build DND binding and indicator for waybar?
        # fancy keys
        "Print" = "exec ${pkgs.grim}/bin/grim -g $(${pkgs.slurp}/bin/slurp)";
        "XF86AudioMicMute" = "exec ${pkgs.avizo}/bin/volumectl -m toggle-mute && pkill -SIGRTMIN+4 waybar";
        "XF86AudioStop" = "exec ${pkgs.playerctl}/bin/playerctl -p spotify stop";
        "XF86MonBrightnessUp" = "exec ${pkgs.avizo}/bin/lightctl up 5";
        "XF86MonBrightnessDown" = "exec ${pkgs.avizo}/bin/lightctl down 5";
        "F5" = "exec sudo ddcutil -d 12 setvcp 10 - 5"; # TODO: fix
        "F6" = "exec sudo ddcutil -d 12 setvcp 10 + 5";
        "XF86Display" = "exec ${pkgs.wdisplays}/bin/wdisplays";
        "XF86Messenger" = "input type:touchpad events toggle enabled disabled";
      };
      assigns = {
        "$workspace1" = [
          {
            instance = "google-chrome";
          }
        ];
        "$workspace5" = [
          {
            app_id = "firefox";
          }
        ];
        "$workspace2" = [
          {
            app_id = "thunderbird";
          }
          {
            instance = "slack";
          }
        ];
        "$workspace3" = [
          {
            app_id = "nemo";
          }
        ];
      };
    };
  };
}
