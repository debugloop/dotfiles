{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    playerctl
  ];
  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      target = "graphical-session.target";
    };
    settings = [
      {
        "layer" = "top";
        "position" = "left";
        "reload_style_on_change" = true;
        "modules-left" = [
          "group/top"
          "idle_inhibitor"
          "group/audio"
          "pulseaudio#mic"
        ];
        "modules-center" = [
          "niri/workspaces"
        ];
        "modules-right" = [
          "systemd-failed-units"
          "tray"
          "battery"
          "clock"
        ];
        "battery" = {
          "rotate" = 90;
          "format" = "";
          "format-discharging" = "{icon} {capacity}% ({time})";
          "format-full" = "";
          "format-icons" = [
            ""
            ""
            ""
            ""
            ""
          ];
          "format-time" = "{H}h {m}m";
          "interval" = 10;
          "states" = {
            "critical" = 10;
            "full" = 95;
            "warning" = 30;
          };
          "tooltip" = true;
        };
        "clock" = {
          "actions" = {
            "on-click-right" = "mode";
            "on-scroll-down" = "shift_up";
            "on-scroll-up" = "shift_down";
          };
          "calendar" = {
            "format" = {
              "days" = "<span color='#dcd7ba'>{}</span>";
              "months" = "<span color='#dcd7ba'>{}</span>";
              "today" = "<span color='#c34043'><b>{}</b></span>";
              "weekdays" = "<span color='#dcd7ba'>{}</span>";
              "weeks" = "<span color='#727169'>W{}</span>";
            };
            "mode" = "month";
            "mode-mon-col" = 3;
            "on-scroll" = 1;
            "weeks-pos" = "left";
          };
          "format" = "{:%H\n%M\n%S}";
          "interval" = 1;
          "tooltip-format" = "<tt>{calendar}</tt>";
        };
        "cpu" = {
          "rotate" = 90;
          "format" = "󰊚 {usage}%";
          "interval" = 5;
          "states" = {
            "critical" = 90;
            "warning" = 70;
          };
        };
        "custom/wincount" = {
          "exec" = pkgs.writeScript "./wincount.sh" ''
            #!/bin/sh

            idfocused="$(niri msg -j workspaces | jq ".[] | select(.is_focused == true ) | .id")"
            num="$(niri msg -j windows | jq "[.[] | select(.workspace_id == $idfocused)] | length")"
            echo $num

            niri msg -j event-stream |\
                while read -r line; do
                    event="$(echo $line | jq --unbuffered -r 'keys.[0]')"
                    case "$event" in
                        "WindowOpenedOrChanged"|"WindowClosed"|"WorkspaceActivated")
                            idfocused="$(niri msg -j workspaces | jq ".[] | select(.is_focused == true ) | .id")"
                            num="$(niri msg -j windows | jq "[.[] | select(.workspace_id == $idfocused)] | length")"
                            echo $num || exit
                            ;;
                    esac
                done
          '';
          "on-scroll-down" = "niri msg action focus-column-right-or-first";
          "on-scroll-up" = "niri msg action focus-column-left-or-last";
        };
        "disk" = {
          "rotate" = 90;
          "format" = "󰋊 {percentage_used}%";
          "interval" = 60;
          "path" = "/nix";
        };
        "idle_inhibitor" = {
          "format" = "{icon}";
          "format-icons" = {
            "activated" = "";
            "deactivated" = "󰒲";
          };
        };
        "group/audio" = {
          "orientation" = "inherit";
          "drawer" = {
            "children-class" = "in-group";
          };
          "modules" = [
            "pulseaudio"
            "pulseaudio/slider"
          ];
        };
        "group/top" = {
          "orientation" = "inherit";
          "drawer" = {
            "click-to-reveal" = true;
            "children-class" = "in-group";
          };
          "modules" = [
            "custom/wincount"
            "cpu"
            "memory"
            "disk"
          ];
        };
        "memory" = {
          "rotate" = 90;
          "format" = " {percentage}%";
          "interval" = 5;
          "states" = {
            "critical" = 90;
            "warning" = 85;
          };
        };
        "niri/window" = {
          "rotate" = 90;
          "format" = "{}";
          "on-scroll-down" = "niri msg action focus-column-right";
          "on-scroll-up" = "niri msg action focus-column-left";
          "separate-outputs" = true;
        };
        "niri/workspaces" = {
          "format" = "<span weight='1000'>{icon}</span>";
          "format-icons" = {
            "active" = "󰄯"; #󰄯  󰬪
            "default" = "󰄰"; #󰺕  󰄰  󰻂  󰻃
          };
          "on-scroll-down" = "niri msg action focus-workspace-down";
          "on-scroll-up" = "niri msg action focus-workspace-up";
          "on-update" = "niri msg -j workspaces | jq -r '.[]|select(.name!=null)|select(.active_window_id==null)|select(.is_active==false).name' | xargs -I{} niri msg action unset-workspace-name {}";
        };
        "pulseaudio" = {
          "format" = "{icon}";
          "format-bluetooth" = "{icon}\n ";
          "format-icons" = {
            "default" = "";
            "speaker" = "";
            "speaker-muted" = "";
          };
          "format-muted" = "{icon}";
          "format-bluetooth-muted" = "{icon}\n ";
          "format-source" = "";
          "format-source-muted" = "";
          "on-click" = "${pkgs.pavucontrol}/bin/pavucontrol";
          "on-click-middle" = "${pkgs.pulseaudio}/bin/pactl set-default-sink $(${pkgs.pulseaudio}/bin/pactl list sinks short | ${pkgs.gnugrep}/bin/grep -v $(${pkgs.pulseaudio}/bin/pactl get-default-sink) | ${pkgs.coreutils}/bin/cut -f 1 | ${pkgs.coreutils}/bin/head -1)";
        };
        "pulseaudio#mic" = {
          "format" = "{format_source}";
          "format-source" = "";
          "format-source-muted" = "";
          "tooltip" = false;
          "on-click" = "bash -c '${pkgs.swayosd}/bin/swayosd-client --input-volume=mute-toggle && pkill -SIGRTMIN+4 waybar'";
        };
        "pulseaudio/slider" = {
          "orientation" = "vertical";
        };
        "systemd-failed-units" = {
          "hide-on-ok" = true;
          "format" = "";
          "system" = true;
          "user" = true;
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
          font-family: "Fira Mono";
          font-size: 12px;
          background: transparent;
          /* exchange with below set */
          background-color: #${config.colors.dark_bg};
      }
      /* exchange with above line */
      .modules-left,
      .modules-center,
      .modules-right {
          background-color: #${config.colors.dark_bg};
          border-radius: 1em;
          /* margin: 0.3em 0.4em; */
      }

      /* workspaces */
      #workspaces {
          padding: 3em 0em;
      }
      #workspaces button {
          color: inherit; /* needed for some reason */
          padding: 0.5em 0.5em;
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
      #workspaces button#niri-workspace-pink {
          color: #${config.colors.pink};
      }
      #workspaces button#niri-workspace-orange {
          color: #${config.colors.orange};
      }
      #workspaces button#niri-workspace-cyan {
          color: #${config.colors.cyan};
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
          padding: 0.6em 0em;
      }

      #pulseaudio.mic {
          color: #${config.colors.background};
          background-color: #${config.colors.red};
      }
      #systemd-failed-units {
          color: #${config.colors.red};
      }

      #pulseaudio-slider trough {
          min-height: 8em;
          min-width: 0.4em;
          border-radius: 0.4em;
          background-color: #${config.colors.light_bg};
      }
      #pulseaudio-slider highlight {
          border-bottom-left-radius: 0.4em;
          border-bottom-right-radius: 0.4em;
          background-color: #${config.colors.blue};
      }
    '';
  };
}
