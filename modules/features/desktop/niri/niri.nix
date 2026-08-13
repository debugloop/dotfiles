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

    home-manager.users.${config.mainUser}.imports = [inputs.self.modules.homeManager.niri];
  };

  flake.modules.homeManager.niri = {
    config,
    pkgs,
    inputs,
    ...
  }: let
    call = pkgs.lib.flip import {
      inherit
        inputs
        kdl
        docs
        binds
        settings
        ;
      inherit (pkgs) lib;
    };
    kdl = call "${inputs.niri}/kdl.nix";
    binds = call "${inputs.niri}/parse-binds.nix";
    docs = call "${inputs.niri}/generate-docs.nix";
    settings = call "${inputs.niri}/settings.nix";
  in {
    imports = [
      ./_animations.nix
      ./_keybindings.nix
      ./_window_rules.nix
    ];

    home.packages = with pkgs; [
      xwayland-satellite
    ];

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
          gaps = 0;
          shadow = {
            enable = false;
            color = "#${config.colors.blue}";
            inactive-color = "#${config.colors.light_bg}00"; # transparent
          };
          focus-ring = {
            enable = false;
            width = 2;
            active.color = "#${config.colors.blue}";
            inactive.color = "#${config.colors.cyan}";
            urgent.color = "#${config.colors.red}";
          };
          border = {
            enable = true;
            width = 3;
            # active.color = "#${config.colors.blue}";
            active.gradient = {
              angle = 135;
              from = "#${config.colors.blue}";
              to = "#${config.colors.bright-blue}";
              relative-to = "window";
            };
            inactive.color = "#${config.colors.light_bg}";
            # urgent.color = "#${config.colors.red}";
            urgent.gradient = {
              angle = 135;
              from = "#${config.colors.red}";
              to = "#${config.colors.bright-red}";
              relative-to = "window";
            };
          };
          default-column-width.proportion = 0.4;
          preset-column-widths = [
            {proportion = 0.3;}
            {proportion = 0.4;}
            {proportion = 0.5;}
            {proportion = 0.6;}
            {proportion = 0.7;}
            {proportion = 1.0;}
          ];
          preset-window-heights = [
            {proportion = 0.333333;}
            {proportion = 0.5;}
            {proportion = 0.666667;}
            {proportion = 1.0;}
          ];
          tab-indicator = {
            position = "right";
            gap = -15;
            width = 8;
            gaps-between-tabs = 8;
            length.total-proportion = 0.2;
            corner-radius = 5;
            # active.color = "#${config.colors.bright-green}88";
            active.gradient = {
              from = "#${config.colors.green}";
              to = "#${config.colors.bright-green}";
            };
            inactive.color = "#${config.colors.light_bg}88";
            # urgent.color = "#${config.colors.red}88";
            urgent.gradient = {
              from = "#${config.colors.red}";
              to = "#${config.colors.bright-red}";
            };
          };
          insert-hint.display.color = "#${config.colors.green}88";
        };
        debug = {
          honor-xdg-activation-with-invalid-serial = true;
        };
      };
      config = with inputs.niri.lib.kdl;
        (settings.render config.programs.niri.settings)
        ++ [
          (leaf "include" ["${./extra.kdl}"])
        ];
    };
  };
}
