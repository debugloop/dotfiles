{inputs, ...}: {
  flake.modules.nixos.display = {config, ...}: {
    age.secrets.wall = {
      file = inputs.self + "/secrets/wall.age";
      mode = "0444";
    };
    home-manager.users.${config.mainUser}.imports = [inputs.self.modules.homeManager.display];
  };

  flake.modules.homeManager.display = {
    config,
    lib,
    osConfig,
    ...
  }: let
    setWallpaper = [
      (lib.getExe config.services.awww.package)
      "img"
      "-t"
      "none"
      osConfig.age.secrets.wall.path
    ];
    setWallpaperCommand = lib.escapeShellArgs setWallpaper;
  in {
    programs.niri.settings.spawn-at-startup = [
      {argv = setWallpaper;}
    ];

    services = {
      awww.enable = true;
      kanshi = {
        enable = true;
        systemdTarget = "graphical-session.target";
        settings = [
          {
            profile = {
              name = "home";
              exec = [setWallpaperCommand];
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
          }
          {
            profile = {
              name = "solo";
              exec = [setWallpaperCommand];
              outputs = [
                {
                  criteria = "eDP-1";
                  status = "enable";
                }
              ];
            };
          }
          {
            profile = {
              name = "other";
              exec = [setWallpaperCommand];
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
            };
          }
        ];
      };
    };
  };
}
