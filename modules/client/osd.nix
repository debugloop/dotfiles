_: {
  flake.modules.homeManager.osd = {
    config,
    pkgs,
    ...
  }: {
    programs.niri.settings.binds = with config.lib.niri.actions; {
      "XF86AudioRaiseVolume" = {
        allow-when-locked = true;
        action = spawn "bash" "-c" "${pkgs.swayosd}/bin/swayosd-client --output-volume=1 && pkill -SIGRTMIN+4 waybar";
      };
      "XF86AudioLowerVolume" = {
        allow-when-locked = true;
        action = spawn "bash" "-c" "${pkgs.swayosd}/bin/swayosd-client --output-volume=-1 && pkill -SIGRTMIN+4 waybar";
      };
      "Shift+XF86AudioRaiseVolume" = {
        allow-when-locked = true;
        action = spawn "bash" "-c" "${pkgs.swayosd}/bin/swayosd-client --output-volume=5 && pkill -SIGRTMIN+4 waybar";
      };
      "Shift+XF86AudioLowerVolume" = {
        allow-when-locked = true;
        action = spawn "bash" "-c" "${pkgs.swayosd}/bin/swayosd-client --output-volume=-5 && pkill -SIGRTMIN+4 waybar";
      };
      "XF86AudioMute" = {
        allow-when-locked = true;
        action = spawn "bash" "-c" "${pkgs.swayosd}/bin/swayosd-client --output-volume=mute-toggle && pkill -SIGRTMIN+4 waybar";
      };
      # TODO: swayosd mic mute broken, pactl added as workaround (will double-toggle when fixed)
      "XF86AudioMicMute" = {
        allow-when-locked = true;
        action = spawn "bash" "-c" "${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle; ${pkgs.swayosd}/bin/swayosd-client --input-volume=mute-toggle && pkill -SIGRTMIN+4 waybar";
      };
      "XF86AudioPlay" = {
        allow-when-locked = true;
        action = spawn "${pkgs.swayosd}/bin/swayosd-client" "--playerctl=play-pause";
      };
      "XF86AudioNext" = {
        allow-when-locked = true;
        action = spawn "${pkgs.swayosd}/bin/swayosd-client" "--playerctl=next";
      };
      "XF86AudioPrev" = {
        allow-when-locked = true;
        action = spawn "${pkgs.swayosd}/bin/swayosd-client" "--playerctl=prev";
      };
      "XF86AudioStop" = {
        allow-when-locked = true;
        action = spawn "${pkgs.swayosd}/bin/swayosd-client" "--playerctl=play-pause";
      };
      "XF86MonBrightnessUp" = {
        action = spawn "${pkgs.swayosd}/bin/swayosd-client" "--brightness=raise";
      };
      "XF86MonBrightnessDown" = {
        action = spawn "${pkgs.swayosd}/bin/swayosd-client" "--brightness=lower";
      };
    };

    services.swayosd = {
      enable = true;
    };
    xdg.configFile."swayosd/config.toml".text = ''
      [server]
      show_percentage = true
    '';
  };
}
