_: {
  flake.modules.nixos.niri = {
    config,
    pkgs,
    inputs,
    ...
  }: {
    imports = [
      inputs.niri.nixosModules.niri
      inputs.niri-autoselect-portal.nixosModules.default
    ];

    services.niri-autoselect-portal.enable = true;

    programs.niri = {
      enable = true;
      package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
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

    home-manager.sharedModules = [inputs.self.modules.homeManager.niri];
  };

  flake.modules.homeManager.niri = {
    config,
    pkgs,
    inputs,
    ...
  }: {
    imports = [
      inputs.self.modules.homeManager.niri_animations
      inputs.self.modules.homeManager.niri_keybindings
      inputs.self.modules.homeManager.niri_window_rules
    ];

    home.packages = with pkgs; [
      xwayland-satellite
    ];
    services.awww.enable = true;
    programs.niri = {
      package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
      settings = {
        gestures.hot-corners.enable = false;
        screenshot-path = "~/pictures/screenshot-%d-%m-%Y-%T.png";
        input = {
          workspace-auto-back-and-forth = true;
          # warp-mouse-to-focus.enable = true;
          focus-follows-mouse = {
            enable = true;
            max-scroll-amount = "0%";
          };
          keyboard = {
            xkb = {
              layout = "eu";
              options = "compose:rctrl,lv3:ralt_switch_multikey";
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
        overview.backdrop-color = "#${config.colors.light_bg}";
        outputs = {
          "eDP-1" = {
            scale = 1.0;
            background-color = "#${config.colors.light_bg}";
          };
          "DP-1" = {
            background-color = "#${config.colors.light_bg}";
          };
          "DP-2" = {
            background-color = "#${config.colors.light_bg}";
          };
        };
        hotkey-overlay.skip-at-startup = true;
        prefer-no-csd = true;
        layout = {
          empty-workspace-above-first = true;
          always-center-single-column = true;
          gaps = 12;
          struts = {
            top = -6;
            bottom = -6;
            left = -6;
            right = -6;
          };
          shadow = {
            enable = false;
            color = "#${config.colors.blue}";
            inactive-color = "#${config.colors.light_bg}00"; # transparent
          };
          focus-ring = {
            enable = true;
            width = 2;
            active.color = "#${config.colors.blue}";
            inactive.color = "#${config.colors.cyan}";
            urgent.color = "#${config.colors.red}";
          };
          border = {
            enable = false;
            width = 1;
            active.color = "#${config.colors.blue}00";
            inactive.color = "#${config.colors.light_bg}00";
            urgent.color = "#${config.colors.red}";
          };
          default-column-width.proportion = 0.4;
          preset-column-widths = [
            {proportion = 0.3;}
            {proportion = 0.4;}
            {proportion = 0.5;}
            {proportion = 0.6;}
            {proportion = 0.7;}
          ];
          preset-window-heights = [
            {proportion = 0.333333;}
            {proportion = 0.5;}
            {proportion = 0.666667;}
          ];
          tab-indicator = {
            position = "top";
            place-within-column = true;
            gap = 5;
            width = 4;
            gaps-between-tabs = 8;
            length.total-proportion = 0.3;
            corner-radius = 5;
            active.color = "#${config.colors.blue}";
            inactive.color = "#${config.colors.light_bg}";
            urgent.color = "#${config.colors.red}";
          };
          insert-hint.display.color = "#${config.colors.green}88";
        };
        debug = {
          honor-xdg-activation-with-invalid-serial = true;
        };
        # workspaces = {
        #   "1-web" = {
        #     name = "web";
        #   };
        #   "2-com" = {
        #     name = "com";
        #   };
        # };
      };
    };
  };
}
