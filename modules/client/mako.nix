_: {
  flake.homeModules.mako = {
    config,
    pkgs,
    ...
  }: {
    xdg.configFile = {
      "systemd/user/notify-failure@.service".text = ''
        [Unit]
        Description=Notify on failed systemd unit %i

        [Service]
        Type=oneshot
        ExecStart=${pkgs.libnotify}/bin/notify-send -u critical -a systemd "Unit failed" "%i"
      '';
      "systemd/user/service.d/on-failure.conf".text = ''
        [Unit]
        OnFailure=notify-failure@%n
      '';
      "systemd/user/notify-failure@.service.d/no-loop.conf".text = ''
        [Unit]
        OnFailure=
      '';
    };

    services.mako = {
      enable = true;
      settings = {
        margin = "10";
        font = "pango:Fira Mono 9";
        anchor = "bottom-right";
        layer = "overlay";
        group-by = "category,summary,body";
        background-color = "#${config.colors.background}";
        border-color = "#${config.colors.blue}";
        border-radius = 5;
        border-size = 3;
        text-color = "#${config.colors.foreground}";
        default-timeout = 7500;
        outer-margin = "20,10";
        "mode=dnd" = {
          invisible = true;
        };
      };
    };
  };
}
