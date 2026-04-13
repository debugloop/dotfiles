_: {
  flake.homeModules.osd = _: {
    services.swayosd = {
      enable = true;
    };
    xdg.configFile."swayosd/config.toml".text = ''
      [server]
      show_percentage = true
    '';
  };
}
