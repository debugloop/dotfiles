{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    pamixer
  ];

  services.swayosd = {
    enable = true;
  };
  xdg.configFile."swayosd/config.toml".text = ''
    [server]
    show_percentage = true
  '';
}
