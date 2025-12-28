{config, ...}: {
  services.mako = {
    enable = true;
    settings = {
      margin = "10";
      font = "pango:Fira Mono 9";
      anchor = "bottom-right";
      layer = "overlay";
      group-by = "category,summary,body";
      background-color = "#${config.colors.background}";
      border-color = "#${config.colors.blue}";
      border-radius = 5;
      border-size = 3;
      text-color = "#${config.colors.foreground}";
      default-timeout = 7500;
      outer-margin = "20,10";
      "mode=dnd" = {
        invisible = true;
      };
    };
  };
}
