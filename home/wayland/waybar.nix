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
        # "position" = "left";
        "layer" = "top";
        "output" = "!HEADLESS-1";
        "modules-left" = [
          "niri/workspaces"
          "niri/window"
          "sway/workspaces"
          "sway/mode"
          "sway/window"
        ];
        "modules-center" = [
          "custom/media"
        ];
        "modules-right" = [
          "pulseaudio"
          "idle_inhibitor"
          "tray"
          "temperature"
          "cpu"
          "memory"
          "disk"
          "battery"
          "custom/weather"
          "clock"
        ];
        "battery" = {
          "interval" = 10;
          "states" = {
            "full" = 95;
            "warning" = 30;
            "critical" = 10;
          };
          "format" = "";
          "format-time" = "{H}h {m}m";
          "format-discharging" = "{icon} {capacity}% ({time})";
          "format-full" = "";
          "format-icons" = [
            ""
            ""
            ""
            ""
            ""
          ];
          "tooltip" = true;
        };
        "clock" = {
          "interval" = 1;
          "format" = "{:%a, %d.%m. %H:%M:%S}";
          "tooltip-format" = "<tt>{calendar}</tt>";
          "calendar" = {
            "mode" = "month";
            "mode-mon-col" = 3;
            "weeks-pos" = "left";
            "on-scroll" = 1;
            "format" = {
              "months" = "<span color='#${config.colors.foreground}'>{}</span>";
              "days" = "<span color='#${config.colors.foreground}'>{}</span>";
              "weeks" = "<span color='#${config.colors.bright-black}'>W{}</span>";
              "weekdays" = "<span color='#${config.colors.foreground}'>{}</span>";
              "today" = "<span color='#${config.colors.red}'><b>{}</b></span>";
            };
          };
          "actions" = {
            "on-click-right" = "mode";
            "on-scroll-up" = "shift_down";
            "on-scroll-down" = "shift_up";
          };
          "locale" = "en_GB.utf-8";
        };
        "custom/media" = {
          "format" = " {icon}{} ";
          "return-type" = "json";
          "format-icons" = {
            "Paused" = " ";
          };
          "max-length" = 80;
          "exec" = ''${pkgs.playerctl}/bin/playerctl -p spotify,vlc metadata --format '{"text": "{{ markup_escape(artist) }} - {{ markup_escape(title) }} ({{duration(position)}}/{{duration(mpris:length)}})", "tooltip": "{{ markup_escape(artist) }} - {{ markup_escape(title) }} ({{duration(position)}}/{{duration(mpris:length)}})", "alt": "{{status}}", "class": "{{status}}"}' -F'';
          "on-click" = "${pkgs.playerctl}/bin/playerctl -p spotify,vlc play-pause";
          "on-click-right" = "${pkgs.playerctl}/bin/playerctl -p spotify,vlc next";
          "on-scroll-down" = "${pkgs.playerctl}/bin/playerctl -p spotify,vlc next";
          "on-scroll-up" = "${pkgs.playerctl}/bin/playerctl -p spotify,vlc previous";
        };
        "custom/weather" = {
          "exec" = "${pkgs.curl}/bin/curl 'https://wttr.in/?format=1'";
          "interval" = 3600;
        };
        "cpu" = {
          "interval" = 5;
          "format" = "󰊚 {usage}%";
          "states" = {
            "warning" = 70;
            "critical" = 90;
          };
        };
        "disk" = {
          "interval" = 60;
          "format" = "󰋊 {percentage_used}%";
          "path" = "/nix";
        };
        "idle_inhibitor" = {
          "format" = "{icon}";
          "format-icons" = {
            "activated" = "";
            "deactivated" = "";
          };
        };
        "memory" = {
          "interval" = 5;
          "format" = " {percentage}%";
          "states" = {
            "warning" = 85;
            "critical" = 90;
          };
        };
        "pulseaudio" = {
          "format" = "{format_source}{icon} {volume}%";
          "format-bluetooth" = "{format_source} {icon} {volume}%";
          "format-source" = "<span color=\"#${config.colors.red}\"></span>  ";
          "format-source-muted" = "";
          "format-muted" = "{format_source} {volume}%";
          "format-icons" = {
            "speaker" = "";
            "default" = "";
          };
          "on-click" = "${pkgs.pavucontrol}/bin/pavucontrol";
          "on-click-middle" = "${pkgs.pulseaudio}/bin/pactl set-default-sink $(${pkgs.pulseaudio}/bin/pactl list sinks short | ${pkgs.gnugrep}/bin/grep -v $(${pkgs.pulseaudio}/bin/pactl get-default-sink) | ${pkgs.coreutils}/bin/cut -f 1 | ${pkgs.coreutils}/bin/head -1)";
          "on-click-right" = "${pkgs.easyeffects}/bin/easyeffects";
        };
        "niri/workspaces" = {
          "format" = "{icon} {value}";
          "format-icons" = {
            "active" = "";
            "default" = "";
          };
          "on-scroll-down" = "niri msg action focus-workspace-down";
          "on-scroll-up" = "niri msg action focus-workspace-up";
        };
        "niri/window" = {
          "format" = "{}";
          "separate-outputs" = true;
          "on-scroll-down" = "niri msg action focus-column-right";
          "on-scroll-up" = "niri msg action focus-column-left";
        };
        "sway/mode" = {
          "format" = " {}";
          "tooltip" = false;
        };
        "sway/window" = {
          "format" = "{}";
          "max-length" = 160;
          #"rewrite" = {
          #  "(.*) — Mozilla Firefox" = " $1";
          #  "(.*) — Evolution" = " $1";
          #  "vim (.*)" = " vim $1";
          #  "fish (.*)" = " $1";
          #};
        };
        "sway/workspaces" = {
          "all-outputs" = false;
          "format" = "{icon} {name}";
          "format-icons" = {
            "1:web" = "";
            "2:com" = "";
            "3:file" = "";
            "4:music" = "";
            "7:term" = "";
            "8:term" = "";
            "9:term" = "";
            "10:term" = "";
            "default" = "";
          };
        };
        "temperature" = {
          #"hwmon-path" = "/sys/class/hwmon/hwmon4/temp1_input";
          "hwmon-path" = "/sys/class/hwmon/hwmon5/temp1_input";
          "critical-threshold" = 99;
          "interval" = 5;
          "format" = "{icon} {temperatureC}°C";
          "format-icons" = [
            ""
            ""
            ""
            ""
            ""
          ];
          "tooltip" = true;
        };
      }
    ];
    style = ''
      * {
        border: none;
        border-radius: 0;
        min-height: 0;
      }
      #waybar {
        background: #${config.colors.dark_bg};
        color: #${config.colors.foreground};
        font-family: "Fira Mono";
        font-size: 13;
      }
      #workspaces {
        background-color: #${config.colors.background};
        padding: 0;
      }
      #workspaces button {
        padding: 0.3em 0.7em;
        color: #${config.colors.foreground};
        border-top: 1px solid #${config.colors.background};
      }
      #workspaces button.empty {
        color: #${config.colors.bright-black};
      }
      #workspaces button.visible {
        border-top: 1px solid #${config.colors.foreground};
      }
      #workspaces button:hover {
        background-color: #${config.colors.background};
        color: #${config.colors.foreground};
        border-top: 1px solid #${config.colors.cyan};
      }
      #workspaces button.focused {
        background-color: #${config.colors.light_bg};
        color: #${config.colors.foreground};
        border-top: 1px solid #${config.colors.blue};
        border-bottom-right-radius: 1em;
      }
      #workspaces button.urgent {
        border-top: 1px solid #${config.colors.red};
      }
      tooltip {
        background: #${config.colors.background};
        color: #${config.colors.foreground};
      }
      /* Each module */
      .modules-left > * > *,
      .modules-center > * > *,
      .modules-right > * > * {
        padding: 0px 0.5em;
      }
      /* all right hand modules */
      .modules-right > * > * {
        margin: 0 0.2em;
      }
      /* settings modules */
      #idle_inhibitor,
      #pulseaudio,
      #tray {
        border-top: 1px solid #${config.colors.dark_fg};
      }
      /* device status modules */
      #battery,
      #cpu,
      #disk,
      #memory,
      #temperature {
        border-top: 1px solid #${config.colors.cyan};
      }
      /* outside status modules */
      #custom-weather,
      #clock {
        border-top: 1px solid #${config.colors.blue};
      }
      #window {
        color: #${config.colors.bright-black};
        background-color: #${config.colors.dark_bg};
      }
      .warning {
        color: #${config.colors.background};
        background-color: #${config.colors.yellow};
      }
      .critical {
        color: #${config.colors.background};
        background-color: #${config.colors.red};
      }
      #custom-media {
        color: rgb(102, 220, 105);
        background-color: #${config.colors.dark_bg};
      }
      #mode {
        background: #${config.colors.purple};
        color: #${config.colors.background};
      }
    '';
  };
}
