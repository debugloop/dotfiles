_: {
  flake.modules.nixos.noctalia = {
    config,
    inputs,
    ...
  }: {
    environment.persistence."/nix/persist".users.${config.mainUser}.directories = [
      ".config/noctalia" # plugins, non-managed config files
      ".cache/noctalia" # wallpapers.json and wallpaper cache
    ];

    home-manager.sharedModules = [inputs.self.modules.homeManager.noctalia];
  };

  flake.modules.homeManager.noctalia = {
    config,
    lib,
    pkgs,
    inputs,
    ...
  }: {
    imports = [inputs.noctalia.homeModules.default];

    programs.noctalia-shell = {
      enable = true;
      settings = ./settings.json;
      plugins = {
        sources = [
          {
            enabled = true;
            name = "Official Noctalia Plugins";
            url = "https://github.com/noctalia-dev/noctalia-plugins";
          }
        ];
        states = {
          privacy-indicator = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
          polkit-agent = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
        };
        version = 2;
      };
    };

    programs.niri.settings = {
      spawn-at-startup = [
        {argv = ["noctalia-shell"];}
      ];
      layer-rules = [
        {
          matches = [{namespace = "noctalia-overview";}];
          place-within-backdrop = true;
        }
      ];
      binds = with config.lib.niri.actions; {
        # launch
        "Mod+D".action = lib.mkForce (spawn "noctalia-shell" "ipc" "call" "launcher" "toggle");

        # lock and suspend
        "Mod+Backslash".action = lib.mkForce (spawn "noctalia-shell" "ipc" "call" "lockScreen" "lock");
        "Mod+Ctrl+Backslash".action = lib.mkForce (spawn "noctalia-shell" "ipc" "call" "sessionMenu" "lockAndSuspend");

        # clipboard (replaces Mod+Shift+V)
        "Mod+Shift+V".action = spawn "noctalia-shell" "ipc" "call" "launcher" "clipboard";

        # notifications (replaces Mod+N)
        "Mod+N".action = spawn "noctalia-shell" "ipc" "call" "notifications" "toggleHistory";
        "Mod+Ctrl+N".action = spawn "noctalia-shell" "ipc" "call" "notifications" "dismissAll";
        "Mod+E".action = spawn "noctalia-shell" "ipc" "call" "controlCenter" "toggle";

        # audio output panel (replaces XF86TouchpadToggle cycleoutput; noctalia has no cycleOutput IPC)
        "XF86TouchpadToggle" = {
          allow-when-locked = true;
          action = spawn "noctalia-shell" "ipc" "call" "volume" "togglePanel";
        };

        # media and brightness
        "XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action = lib.mkForce (spawn "bash" "-c" "noctalia-shell ipc call volume increase; ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%");
        };
        "XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action = lib.mkForce (spawn "bash" "-c" "noctalia-shell ipc call volume decrease; ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%");
        };
        "XF86AudioMute" = {
          allow-when-locked = true;
          action = lib.mkForce (spawn "noctalia-shell" "ipc" "call" "volume" "muteOutput");
        };
        "XF86AudioMicMute" = {
          allow-when-locked = true;
          action = lib.mkForce (spawn "noctalia-shell" "ipc" "call" "volume" "muteInput");
        };
        "XF86AudioPlay" = {
          allow-when-locked = true;
          action = lib.mkForce (spawn "noctalia-shell" "ipc" "call" "media" "playPause");
        };
        "XF86AudioNext" = {
          allow-when-locked = true;
          action = lib.mkForce (spawn "noctalia-shell" "ipc" "call" "media" "next");
        };
        "XF86AudioPrev" = {
          allow-when-locked = true;
          action = lib.mkForce (spawn "noctalia-shell" "ipc" "call" "media" "previous");
        };
        "XF86AudioStop" = {
          allow-when-locked = true;
          action = lib.mkForce (spawn "noctalia-shell" "ipc" "call" "media" "playPause");
        };
        "XF86MonBrightnessUp" = {
          allow-when-locked = true;
          action = lib.mkForce (spawn "noctalia-shell" "ipc" "call" "brightness" "increase");
        };
        "XF86MonBrightnessDown" = {
          allow-when-locked = true;
          action = lib.mkForce (spawn "noctalia-shell" "ipc" "call" "brightness" "decrease");
        };
      };
    };
  };
}
