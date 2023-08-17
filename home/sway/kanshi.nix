{ pkgs, ... }:

{
  services.kanshi = {
    enable = true;
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
            criteria = "*";
            status = "disable";
          }
        ];
      };
      other = {
        outputs = [
          {
            criteria = "*";
            status = "enable";
          }
        ];
      };
    };
  };
}
