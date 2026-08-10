{config, ...}: {
  programs.niri.settings = {
    window-rules = [
      {
        clip-to-geometry = true;
        # geometry-corner-radius = {
        #   bottom-left = 0.0;
        #   bottom-right = 10.0;
        #   top-left = 10.0;
        #   top-right = 0.0;
        # };
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
          {is-window-cast-target = true;}
        ];
        border = {
          active.color = "#${config.colors.bright-red}";
          inactive.color = "#${config.colors.bright-red}";
        };
        shadow = {
          enable = true;
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
          inactive-color = "#${config.colors.light_bg}";
        };
        geometry-corner-radius = {
          bottom-left = 10.0;
          bottom-right = 10.0;
          top-left = 10.0;
          top-right = 10.0;
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
}
