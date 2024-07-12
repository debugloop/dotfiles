{ pkgs, ... }:

{
  services.swayidle = {
    enable = true;
    systemdTarget = "graphical-session.target";
    timeouts = [
      {
        timeout = 300;
        command = "echo '5min idle timeout'; if ${pkgs.procps}/bin/pgrep swaylock; then echo 'already locked'; else echo 'locking!' && ${pkgs.swaylock-effects}/bin/swaylock -f; fi";
      }
    ];
    events = [
      {
        event = "before-sleep";
        command = "echo 'before-sleep hook'; if ${pkgs.procps}/bin/pgrep swaylock; then echo 'already locked'; else echo 'locking!' && ${pkgs.swaylock-effects}/bin/swaylock -f --grace=0; fi";
      }
      {
        event = "after-resume";
        command = "echo 'after-resume hook'; ${pkgs.systemd}/bin/systemctl --user kill -sSIGHUP kanshi";
      }
    ];
  };
}
