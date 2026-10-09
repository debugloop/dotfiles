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
    pkgs,
    ...
  }: let
    backdropEnabled = config.wallpaper.backdrop;
    waitForOutput = pkgs.writeShellApplication {
      name = "awww-wait-for-output";
      runtimeInputs = [config.services.awww.package pkgs.coreutils];
      text = builtins.readFile ./_wait_for_awww_output.sh;
    };
    waitForOutputCommand = [
      (lib.getExe' pkgs.coreutils "timeout")
      "10s"
      (lib.getExe waitForOutput)
    ];
    wallpaperCommand =
      [
        (lib.getExe config.services.awww.package)
        "img"
        "-t"
        "none"
        config.wallpaper.path
      ]
      ++ config.wallpaper.extraArgs;
    setWallpaper = wallpaperCommand ++ lib.optionals backdropEnabled ["--all"];
    setWallpaperCommand = lib.escapeShellArgs setWallpaper;
  in {
    options.wallpaper = {
      path = lib.mkOption {
        type = lib.types.str;
        default = osConfig.age.secrets.wall.path;
        description = "Path to the wallpaper image.";
      };
      backdrop = lib.mkEnableOption "the same wallpaper in the overview backdrop";
      extraArgs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Additional arguments for the awww image command.";
      };
    };

    config = {
      wayland.windowManager.niri.settings._children = lib.optionals backdropEnabled [
        {
          layer-rule = {
            match._props.namespace = "^awww-daemonbackdrop$";
            place-within-backdrop = true;
          };
        }
      ];

      systemd.user.services.awww.Service = {
        Type = "notify";
        TimeoutStartSec = "30s";
        ExecStartPost = [
          (lib.escapeShellArgs waitForOutputCommand)
          (lib.escapeShellArgs wallpaperCommand)
        ];
      };
      systemd.user.services.awww-backdrop = lib.mkIf backdropEnabled {
        Unit = {
          Description = "awww overview backdrop";
          ConditionEnvironment = "WAYLAND_DISPLAY";
          After = [config.wayland.systemd.target];
          PartOf = [config.wayland.systemd.target];
        };
        Install.WantedBy = [config.wayland.systemd.target];
        Service = {
          Type = "notify";
          TimeoutStartSec = "30s";
          Environment = ["PATH=${lib.makeBinPath [config.services.awww.package]}"];
          ExecStart = lib.escapeShellArgs [
            (lib.getExe' config.services.awww.package "awww-daemon")
            "--namespace"
            "backdrop"
            "--layer"
            "background"
          ];
          ExecStartPost = [
            (lib.escapeShellArgs (waitForOutputCommand ++ ["--namespace" "backdrop"]))
            (lib.escapeShellArgs (wallpaperCommand ++ ["--namespace" "backdrop"]))
          ];
          Restart = "on-failure";
          RestartSec = 1;
        };
      };

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
  };
}
