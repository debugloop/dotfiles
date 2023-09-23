{ pkgs, ... }:

{
  services.kanshi = {
    enable = true;
    systemdTarget = "graphical-session.target";
    profiles = {
      home_initial = {
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
        ];
      };
      home = {
        outputs = [
          {
            criteria = "LG Electronics LG ULTRAWIDE 208NTKF4V093";
            mode = "3440x1440@60Hz";
            position = "0,0";
            status = "enable";
          }
        ];
      };
      solo = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
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
