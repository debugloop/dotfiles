_: {
  flake.modules.homeManager.osd = {pkgs, ...}: {
    wayland.windowManager.niri.settings.binds = {
      "XF86AudioRaiseVolume" = {
        _props.allow-when-locked = true;
        spawn = ["bash" "-c" "${pkgs.swayosd}/bin/swayosd-client --output-volume=1 && pkill -SIGRTMIN+4 waybar"];
      };
      "XF86AudioLowerVolume" = {
        _props.allow-when-locked = true;
        spawn = ["bash" "-c" "${pkgs.swayosd}/bin/swayosd-client --output-volume=-1 && pkill -SIGRTMIN+4 waybar"];
      };
      "Shift+XF86AudioRaiseVolume" = {
        _props.allow-when-locked = true;
        spawn = ["bash" "-c" "${pkgs.swayosd}/bin/swayosd-client --output-volume=5 && pkill -SIGRTMIN+4 waybar"];
      };
      "Shift+XF86AudioLowerVolume" = {
        _props.allow-when-locked = true;
        spawn = ["bash" "-c" "${pkgs.swayosd}/bin/swayosd-client --output-volume=-5 && pkill -SIGRTMIN+4 waybar"];
      };
      "XF86AudioMute" = {
        _props.allow-when-locked = true;
        spawn = ["bash" "-c" "${pkgs.swayosd}/bin/swayosd-client --output-volume=mute-toggle && pkill -SIGRTMIN+4 waybar"];
      };
      "XF86AudioMicMute" = {
        _props.allow-when-locked = true;
        spawn = ["bash" "-c" "${pkgs.swayosd}/bin/swayosd-client --input-volume=mute-toggle && pkill -SIGRTMIN+4 waybar"];
      };
      "XF86AudioPlay" = {
        _props.allow-when-locked = true;
        spawn = ["${pkgs.swayosd}/bin/swayosd-client" "--playerctl=play-pause"];
      };
      "XF86AudioNext" = {
        _props.allow-when-locked = true;
        spawn = ["${pkgs.swayosd}/bin/swayosd-client" "--playerctl=next"];
      };
      "XF86AudioPrev" = {
        _props.allow-when-locked = true;
        spawn = ["${pkgs.swayosd}/bin/swayosd-client" "--playerctl=prev"];
      };
      "XF86AudioStop" = {
        _props.allow-when-locked = true;
        spawn = ["${pkgs.swayosd}/bin/swayosd-client" "--playerctl=play-pause"];
      };
      "XF86MonBrightnessUp".spawn = ["${pkgs.swayosd}/bin/swayosd-client" "--brightness=raise"];
      "XF86MonBrightnessDown".spawn = ["${pkgs.swayosd}/bin/swayosd-client" "--brightness=lower"];
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
