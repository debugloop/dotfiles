{
  pkgs,
  config,
  ...
}: {
  services.mako = {
    enable = true;
    font = "pango:Fira Mono 9";
    backgroundColor = "#${config.colors.background}";
    borderColor = "#${config.colors.blue}";
    borderRadius = 5;
    borderSize = 3;
    textColor = "#${config.colors.foreground}";
    defaultTimeout = 7500;
    extraConfig = ''
      [mode=dnd]
      invisible=1
    '';
  };
}
