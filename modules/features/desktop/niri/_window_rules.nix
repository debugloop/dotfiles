{config, ...}: {
  wayland.windowManager.niri.settings._children = [
    {
      window-rule.clip-to-geometry = true;
    }
    {
      window-rule._children = [
        {
          match._props.title = "^\\[private\\] .*$";
        }
        {
          block-out-from = "screencast";
        }
      ];
    }
    {
      window-rule._children = [
        {
          match._props = {
            app-id = "firefox";
            title = "Picture-in-Picture";
          };
        }
        {
          open-floating = true;
        }
      ];
    }
    {
      window-rule._children = [
        {
          match._props.app-id = "kitty";
        }
        {
          default-column-width.proportion = 0.2;
        }
      ];
    }
    {
      window-rule._children = [
        {
          match._props.is-window-cast-target = true;
        }
        {
          border = {
            active-color = "#${config.colors.bright-red}";
            inactive-color = "#${config.colors.bright-red}";
          };
        }
        {
          shadow = {
            on = {};
            color = "#${config.colors.bright-red}";
          };
        }
      ];
    }
    {
      window-rule._children = [
        {
          match._props.is-floating = true;
        }
        {
          geometry-corner-radius = [
            10.0
            10.0
            10.0
            10.0
          ];
        }
        {
          shadow = {
            on = {};
            color = "#${config.colors.blue}";
            inactive-color = "#${config.colors.light_bg}";
          };
        }
      ];
    }
    {
      layer-rule._children = [
        {
          match._props.namespace = "notifications";
        }
        {
          block-out-from = "screen-capture";
        }
      ];
    }
  ];
}
