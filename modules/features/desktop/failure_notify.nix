_: {
  flake.modules.homeManager.failure_notify = {pkgs, ...}: {
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
  };
}
