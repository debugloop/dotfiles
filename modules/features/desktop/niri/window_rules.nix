_: {
  flake.modules.homeManager.niri_window_rules = {config, ...}: {
    programs.niri.settings = {
      window-rules = [
        {
          clip-to-geometry = true;
          geometry-corner-radius = {
            bottom-left = 0.0;
            bottom-right = 10.0;
            top-left = 10.0;
            top-right = 0.0;
          };
        }
        {
          matches = [
            {title = "^\\[private\\] .*$";}
          ];
          block-out-from = "screencast";
        }
        {
          matches = [
            {
              title = "Picture-in-Picture";
              app-id = "firefox";
            }
          ];
          open-floating = true;
        }
        {
          matches = [
            {app-id = "kitty";}
          ];
          default-column-width = {proportion = 0.3;};
        }
        {
          matches = [
            {is-urgent = true;}
          ];
          shadow = {
            enable = true;
            softness = 0;
            spread = 2;
            offset = {
              x = 0;
              y = 0;
            };
            color = "#${config.colors.bright-red}";
          };
        }
        {
          matches = [
            {is-window-cast-target = true;}
          ];
          focus-ring = {
            enable = true;
            width = 1;
            active.color = "#${config.colors.bright-red}";
            inactive.color = "#${config.colors.bright-red}";
          };
          border = {
            enable = true;
            width = 1;
            active.color = "#${config.colors.bright-red}00";
            inactive.color = "#${config.colors.bright-red}00";
          };
          shadow = {
            enable = true;
            softness = 8;
            spread = 3;
            offset = {
              x = 0;
              y = 0;
            };
            color = "#${config.colors.bright-red}";
          };
        }
        {
          matches = [
            {is-floating = true;}
          ];
          shadow = {
            enable = true;
            color = "#${config.colors.blue}";
          };
        }
      ];
      layer-rules = [
        {
          matches = [
            {namespace = "notifications";}
          ];
          block-out-from = "screen-capture";
        }
      ];
    };
  };
}
