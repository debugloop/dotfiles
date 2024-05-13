{ pkgs, ... }:

{
  services.kanshi = {
    enable = true;
    systemdTarget = "graphical-session.target";
    profiles = {
      home = {
        outputs = [
          {
            criteria = "LG Electronics LG ULTRAWIDE 208NTKF4V093";
            mode = "3440x1440@60Hz";
            position = "0,0";
            status = "enable";
          }
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "HEADLESS-1";
          }
        ];
      };
      solo = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
          }
          {
            criteria = "HEADLESS-1";
          }
        ];
        exec = [
          "systemctl --user start swayidle.service"
        ];
      };
      other = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
          }
          {
            criteria = "HEADLESS-1";
          }
          {
            criteria = "*";
            status = "enable";
          }
        ];
        exec = [
          "systemctl --user start swayidle.service"
        ];
      };
    };
  };
}
