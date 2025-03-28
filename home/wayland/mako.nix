{config, ...}: {
  services.mako = {
    enable = true;
    margin = "10";
    font = "pango:Fira Mono 9";
    anchor = "bottom-left";
    layer = "overlay";
    groupBy = "category,summary,body";
    backgroundColor = "#${config.colors.background}";
    borderColor = "#${config.colors.blue}";
    borderRadius = 5;
    borderSize = 3;
    textColor = "#${config.colors.foreground}";
    defaultTimeout = 7500;
    extraConfig = ''
      outer-margin=20,10
      [mode=dnd]
      invisible=1
    '';
  };
}
