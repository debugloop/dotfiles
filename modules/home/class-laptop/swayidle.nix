{
  perSystem,
  pkgs,
  ...
}: {
  services.swayidle = {
    enable = true;
    systemdTarget = "graphical-session.target";
    timeouts = [
      {
        timeout = 300;
        command = "echo '5min idle timeout, locking' && ${perSystem.noctalia.default}/bin/noctalia-shell ipc call lockScreen lock";
      }
      {
        timeout = 360;
        command = "echo '6min idle timeout, turning off monitors' && ${pkgs.niri}/bin/niri msg action power-off-monitors";
      }
    ];
    events = [
      {
        event = "before-sleep";
        command = "echo 'going to sleep, locking' && ${perSystem.noctalia.default}/bin/noctalia-shell ipc call lockScreen lock";
      }
      {
        event = "after-resume";
        command = "echo 'after-resume hook'; ${pkgs.systemd}/bin/systemctl --user kill -sSIGHUP kanshi";
      }
    ];
  };
}
