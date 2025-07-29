{...}: {
  services.kanshi = {
    enable = true;
    systemdTarget = "graphical-session.target";
    settings = [
      {
        profile.name = "home";
        profile.outputs = [
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
      }
      {
        profile.name = "solo";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
          }
        ];
      }
      {
        profile.name = "other";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
          }
          {
            criteria = "*";
            status = "enable";
          }
        ];
      }
    ];
  };
}
