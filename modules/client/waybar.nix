_: {
  flake.modules.homeManager.waybar = {
    pkgs,
    config,
    lib,
    ...
  }: {
    programs.niri.settings.binds = with config.lib.niri.actions; {
      "Mod+Ctrl+1".action = set-workspace-name "red";
      "Mod+Ctrl+2".action = set-workspace-name "green";
      "Mod+Ctrl+3".action = set-workspace-name "blue";
      "Mod+Ctrl+4".action = set-workspace-name "orange";
      "Mod+Ctrl+5".action = set-workspace-name "yellow";
      "Mod+Ctrl+6".action = set-workspace-name "purple";
      "Mod+Ctrl+0".action = unset-workspace-name;

      "Mod+Shift+1".action = lib.mkForce (spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"red\")' && niri msg action move-window-to-workspace red || niri msg action move-window-to-workspace 42 && niri msg action set-workspace-name red");
      "Mod+Shift+2".action = lib.mkForce (spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"green\")' && niri msg action move-window-to-workspace green || niri msg action move-window-to-workspace 42 && niri msg action set-workspace-name green");
      "Mod+Shift+3".action = lib.mkForce (spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"blue\")' && niri msg action move-window-to-workspace blue || niri msg action move-window-to-workspace 42 && niri msg action set-workspace-name blue");
      "Mod+Shift+4".action = lib.mkForce (spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"orange\")' && niri msg action move-window-to-workspace orange || niri msg action move-window-to-workspace 42 && niri msg action set-workspace-name orange");
      "Mod+Shift+5".action = lib.mkForce (spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"yellow\")' && niri msg action move-window-to-workspace yellow || niri msg action move-window-to-workspace 42 && niri msg action set-workspace-name yellow");
      "Mod+Shift+6".action = lib.mkForce (spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"purple\")' && niri msg action move-window-to-workspace purple || niri msg action move-window-to-workspace 42 && niri msg action set-workspace-name purple");

      "Mod+1".action = lib.mkForce (spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"red\")' && niri msg action focus-workspace red || niri msg action focus-workspace 64 && niri msg action set-workspace-name red");
      "Mod+2".action = lib.mkForce (spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"green\")' && niri msg action focus-workspace green || niri msg action focus-workspace 64 && niri msg action set-workspace-name green");
      "Mod+3".action = lib.mkForce (spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"blue\")' && niri msg action focus-workspace blue || niri msg action focus-workspace 64 && niri msg action set-workspace-name blue");
      "Mod+4".action = lib.mkForce (spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"orange\")' && niri msg action focus-workspace orange || niri msg action focus-workspace 64 && niri msg action set-workspace-name orange");
      "Mod+5".action = lib.mkForce (spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"yellow\")' && niri msg action focus-workspace yellow || niri msg action focus-workspace 64 && niri msg action set-workspace-name yellow");
      "Mod+6".action = lib.mkForce (spawn "fish" "-c" "niri msg -j workspaces | jq -er '.[]|select(.name==\"purple\")' && niri msg action focus-workspace purple || niri msg action focus-workspace 64 && niri msg action set-workspace-name purple");
    };

    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
        targets = ["graphical-session.target"];
      };
      settings = [
        {
          layer = "top";
          position = "left";
          reload_style_on_change = true;
          modules-left = [
            "niri/workspaces"
          ];
          modules-center = [
            "pulseaudio#mic"
            "custom/casts"
          ];
          modules-right = [
            "group/audio"
            "battery"
            "network"
            "idle_inhibitor"
            "group/bottom"
            "clock"
          ];
          battery = {
            rotate = 90;
            format = "";
            format-discharging = "{icon} {capacity}% ({time})";
            format-full = "";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
            ];
            format-time = "{H}h {m}m";
            interval = 10;
            states = {
              critical = 10;
              full = 95;
              warning = 30;
            };
            tooltip = true;
          };
          clock = {
            calendar = {
              format = {
                days = "<span color='#${config.colors.foreground}'>{}</span>";
                months = "<span color='#${config.colors.foreground}'>{}</span>";
                today = "<span color='#${config.colors.red}'><b>{}</b></span>";
                weekdays = "<span color='#${config.colors.foreground}'>{}</span>";
                weeks = "<span color='#${config.colors.bright-black}'>W{}</span>";
              };
              mode = "year";
              mode-mon-col = 3;
              weeks-pos = "left";
            };
            format = "{:%H\n%M\n%S}";
            interval = 1;
            tooltip-format = "<tt>{calendar}</tt>";
          };
          "clock#date" = {
            calendar = {
              format = {
                days = "<span color='#${config.colors.foreground}'>{}</span>";
                months = "<span color='#${config.colors.foreground}'>{}</span>";
                today = "<span color='#${config.colors.red}'><b>{}</b></span>";
                weekdays = "<span color='#${config.colors.foreground}'>{}</span>";
                weeks = "<span color='#${config.colors.bright-black}'>W{}</span>";
              };
              mode = "year";
              mode-mon-col = 3;
              weeks-pos = "left";
            };
            format = "{:%d\n%m}";
            tooltip-format = "<tt>{calendar}</tt>";
          };
          cpu = {
            rotate = 90;
            format = "󰊚 {usage}%";
            interval = 5;
            states = {
              critical = 90;
              warning = 70;
            };
          };
          disk = {
            rotate = 90;
            format = "󰋊 {percentage_used}%";
            interval = 60;
            path = "/nix";
          };
          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = "";
              deactivated = "󰒲";
            };
          };
          "group/audio" = {
            orientation = "inherit";
            drawer = {
              children-class = "in-group";
              transition-left-to-right = false;
            };
            modules = [
              "pulseaudio"
              "pulseaudio/slider"
            ];
          };
          "group/bottom" = {
            orientation = "inherit";
            drawer = {
              click-to-reveal = true;
              transition-left-to-right = false;
              children-class = "in-group";
            };
            modules = [
              "clock#date"
              "cpu"
              "memory"
              "disk"
            ];
          };
          memory = {
            rotate = 90;
            format = " {percentage}%";
            interval = 5;
            states = {
              critical = 90;
              warning = 85;
            };
          };
          network = {
            format = "";
            format-wifi = "{icon}";
            format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
            format-ethernet = "󰈀";
            format-disconnected = "￤";
            format-disabled = "";
            on-click = "nmgui";
            tooltip-format-wifi = "{essid} ({signalStrength}%)";
          };
          "niri/workspaces" = {
            format = "<span weight='1000'>{icon}</span>";
            format-icons = {
              active = "󰄯";
              default = "󰄰";
            };
            on-scroll-down = "niri msg action focus-workspace-down";
            on-scroll-up = "niri msg action focus-workspace-up";
            on-update = "niri msg -j workspaces | jq -r '.[]|select(.name!=null)|select(.active_window_id==null)|select(.is_active==false).name' | xargs -I{} niri msg action unset-workspace-name {}";
          };
          pulseaudio = {
            format = "{icon}";
            format-bluetooth = "{icon}\n ";
            format-icons = {
              default = "";
              speaker = "";
              speaker-muted = "";
            };
            format-muted = "{icon}";
            format-bluetooth-muted = "{icon}\n ";
            format-source = "";
            format-source-muted = "";
            on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
            on-click-middle = "${pkgs.pulseaudio}/bin/pactl set-default-sink $(${pkgs.pulseaudio}/bin/pactl list sinks short | ${pkgs.gnugrep}/bin/grep -v $(${pkgs.pulseaudio}/bin/pactl get-default-sink) | ${pkgs.coreutils}/bin/cut -f 1 | ${pkgs.coreutils}/bin/head -1)";
          };
          "pulseaudio#mic" = {
            format = "{format_source}";
            format-source = "";
            format-source-muted = "";
            tooltip = false;
            # TODO: swayosd mic mute broken, pactl added as workaround (will double-toggle when fixed)
            on-click = "bash -c '${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle; ${pkgs.swayosd}/bin/swayosd-client --input-volume=mute-toggle && pkill -SIGRTMIN+4 waybar'";
          };
          "pulseaudio/slider" = {
            orientation = "vertical";
          };
          "custom/casts" = {
            exec = "niri msg --json casts | ${pkgs.jq}/bin/jq -e 'any(.[]; (.target | keys) - [\"Nothing\"] | length > 0)' >/dev/null 2>&1 && echo ''";
            interval = 2;
            tooltip = false;
          };
        }
      ];
      style = ''
        * {
            border: none;
            border-radius: 0;
            min-height: 0;
            min-width: 0;
            padding: 0;
            margin: 0;
        }

        /* the bar itself */
        #waybar {
            color: #${config.colors.foreground};
            font-family: "Iosevka";
            font-size: 12px;
            background-color: alpha(#${config.colors.dark_bg}, 0.5);
        }
        .modules-left,
        .modules-center,
        .modules-right {
            background-color: alpha(#${config.colors.dark_bg}, 0.8);
            border-radius: 1em;
        }
        .modules-left,
        .modules-right {
            margin: 0.3em 0.4em;
        }
        .modules-center {
            margin: 0;
            background-color: transparent;
        }

        /* workspaces */
        #workspaces {
            padding: 0.5em 0em;
        }
        #workspaces button {
            color: inherit; /* needed for some reason */
            padding: 0.5em;
        }

        #workspaces button.visible {
        }
        #workspaces button:hover {
            background-color: #${config.colors.background};
        }
        #workspaces button.focused {
        }
        #workspaces button.urgent {
        }
        #workspaces button.empty {
            color: #${config.colors.bright-black};
        }
        #workspaces button#niri-workspace-red {
            color: #${config.colors.red};
        }
        #workspaces button#niri-workspace-green {
            color: #${config.colors.green};
        }
        #workspaces button#niri-workspace-blue {
            color: #${config.colors.blue};
        }
        #workspaces button#niri-workspace-orange {
            color: #${config.colors.orange};
        }
        #workspaces button#niri-workspace-purple {
            color: #${config.colors.purple};
        }
        #workspaces button#niri-workspace-yellow {
            color: #${config.colors.yellow};
        }

        /* darker tooltips */
        tooltip {
            background: #${config.colors.background};
            color: #${config.colors.bright-white};
        }

        .module {
            padding: 0.6em 0.3em;
        }

        #clock {
            padding-top: 0em;
        }

        #pulseaudio.mic,
        #custom-casts {
            color: #${config.colors.background};
            padding: 1em 0;
        }
        #pulseaudio.mic {
            background-color: #${config.colors.red};
        }
        #custom-casts {
            background-color: #${config.colors.purple};
        }

        #pulseaudio-slider trough {
            min-height: 8em;
            min-width: 0.4em;
            border-radius: 0.4em;
            background-color: alpha(#${config.colors.light_bg}, 0.2);
        }
        #pulseaudio-slider highlight {
            border-bottom-left-radius: 0.4em;
            border-bottom-right-radius: 0.4em;
            background-color: #${config.colors.blue};
        }
      '';
    };
  };
}
