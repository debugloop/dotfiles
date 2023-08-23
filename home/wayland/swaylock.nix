{ pkgs, config, ... }:

{
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      screenshots = true;
      effect-blur = "5x5";
      fade-in = 0.5;
      grace = 5;
      grace-no-mouse = true;
      clock = true;
      datestr = "%a, %d.%m.%Y";
      indicator = true;
      ignore-empty-password = true;
      show-failed-attempts = true;
      indicator-radius = 300;
      indicator-thickness = 30;
      color = "${config.colors.background}ff";
      inside-color = "${config.colors.background}00";
      inside-ver-color = "${config.colors.background}00";
      inside-clear-color = "${config.colors.background}00";
      inside-wrong-color = "${config.colors.background}00";
      separator-color = "${config.colors.background}00";
      key-hl-color = "${config.colors.cyan}";
      bs-hl-color = "${config.colors.red}";
      line-uses-inside = true;
      ring-color = "${config.colors.background}00";
      text-color = "${config.colors.foreground}ff";
      ring-clear-color = "${config.colors.background}00";
      text-clear-color = "${config.colors.foreground}ff";
      ring-ver-color = "${config.colors.blue}ff";
      text-ver-color = "${config.colors.background}00";
      ring-wrong-color = "${config.colors.red}ff";
      text-wrong-color = "${config.colors.red}ff";
    };
  };
}
