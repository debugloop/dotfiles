_: {
  flake.modules.nixos.niri = {
    config,
    pkgs,
    inputs,
    ...
  }: {
    imports = [inputs.niri-autoselect-portal.nixosModules.default];

    services.niri-autoselect-portal.enable = true;

    programs.niri = {
      enable = true;
      package = pkgs.niri;
      useNautilus = false;
    };

    systemd.user.services.niri-polkit = {
      description = "PolicyKit authentication agent for Niri";
      after = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
      wantedBy = ["niri.service"];
      serviceConfig = {
        ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      config = {
        common = {
          default = [
            "gnome"
            "gtk"
          ];
          "org.freedesktop.impl.portal.FileChooser" = "gtk";
          "org.freedesktop.impl.portal.Access" = "gtk";
          "org.freedesktop.impl.portal.Notification" = "gtk";
          "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
        };
      };
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };

    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "niri-session";
        user = config.mainUser;
      };
    };

    home-manager.users.${config.mainUser}.imports = [inputs.self.modules.homeManager.niri];
  };

  flake.modules.homeManager.niri = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      ./_animations.nix
      ./_keybindings.nix
      ./_window_rules.nix
    ];

    wayland.windowManager.niri = {
      enable = true;
      package = pkgs.niri;
      systemd.enable = false;
      portalPackage = null;
      xwaylandSatellitePackage = pkgs.xwayland-satellite;

      settings = {
        _children = [
          {
            output = {
              _args = ["DP-1"];
              background-color = "#${config.colors.light_bg}";
              transform = "normal";
            };
          }
          {
            output = {
              _args = ["DP-2"];
              background-color = "#${config.colors.light_bg}";
              transform = "normal";
            };
          }
          {
            output = {
              _args = ["eDP-1"];
              background-color = "#${config.colors.light_bg}";
              scale = 1.0;
              transform = "normal";
            };
          }
        ];

        cursor = {
          xcursor-theme = "default";
          xcursor-size = 24;
        };
        debug.honor-xdg-activation-with-invalid-serial = true;
        gestures.hot-corners.off = {};
        hotkey-overlay.skip-at-startup = {};
        input = {
          focus-follows-mouse._props.max-scroll-amount = "0%";
          keyboard = {
            repeat-delay = 600;
            repeat-rate = 25;
            track-layout = "global";
            xkb = {
              layout = "eu";
              model = "";
              options = "compose:rctrl,lv3:ralt_switch_multikey";
              rules = "";
              variant = "";
            };
          };
          touchpad = {
            accel-profile = "adaptive";
            accel-speed = 0.4;
            dwt = {};
            middle-emulation = {};
            natural-scroll = {};
            tap = {};
          };
          workspace-auto-back-and-forth = {};
        };
        layout = {
          always-center-single-column = {};
          border = {
            active-gradient._props = {
              angle = 135;
              from = "#${config.colors.blue}";
              relative-to = "window";
              to = "#${config.colors.bright-blue}";
            };
            inactive-color = "#${config.colors.light_bg}";
            urgent-gradient._props = {
              angle = 135;
              from = "#${config.colors.red}";
              relative-to = "window";
              to = "#${config.colors.bright-red}";
            };
            width = 3;
          };
          center-focused-column = "never";
          default-column-width.proportion = 0.25;
          empty-workspace-above-first = {};
          focus-ring.off = {};
          gaps = 0;
          insert-hint.color = "#${config.colors.green}88";
          preset-column-widths._children = [
            {proportion = 0.2;}
            {proportion = 0.25;}
            {proportion = 0.3;}
            {proportion = 0.35;}
            {proportion = 0.4;}
            {proportion = 0.45;}
            {proportion = 0.5;}
            {proportion = 0.6;}
            {proportion = 0.7;}
            {proportion = 0.8;}
          ];
          preset-window-heights._children = [
            {proportion = 0.333333;}
            {proportion = 0.5;}
            {proportion = 0.666667;}
            {proportion = 1.0;}
          ];
          struts = {
            bottom = 0;
            left = 0;
            right = 0;
            top = 0;
          };
          tab-indicator = {
            active-gradient._props = {
              angle = 180;
              from = "#${config.colors.green}";
              relative-to = "window";
              to = "#${config.colors.bright-green}";
            };
            corner-radius = 5;
            gap = -15;
            gaps-between-tabs = 8;
            inactive-color = "#${config.colors.light_bg}88";
            length._props.total-proportion = 0.2;
            position = "right";
            urgent-gradient._props = {
              angle = 180;
              from = "#${config.colors.red}";
              relative-to = "window";
              to = "#${config.colors.bright-red}";
            };
            width = 8;
          };
        };
        overview.backdrop-color = "#${config.colors.light_bg}";
        prefer-no-csd = {};
        screenshot-path = "~/pictures/screenshot-%d-%m-%Y-%T.png";
      };

      extraConfig = ''include "${./extra.kdl}"'';
    };
  };
}
