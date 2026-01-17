{pkgs, ...}: {
  services.swayidle = {
    enable = true;
    systemdTarget = "graphical-session.target";
    timeouts = [
      {
        timeout = 60;
        command = "echo '1min idle timeout'; if ${pkgs.procps}/bin/pgrep swaylock; then echo 'already locked, power off monitors!' && ${pkgs.niri}/bin/niri msg action power-off-monitors; fi";
      }
      {
        timeout = 300;
        command = "echo '5min idle timeout'; if ${pkgs.procps}/bin/pgrep swaylock; then echo 'already locked'; else echo 'locking!' && ${pkgs.swaylock-effects}/bin/swaylock -f; fi";
      }
      {
        timeout = 360;
        command = "echo '6min idle timeout, turning off monitors' && ${pkgs.niri}/bin/niri msg action power-off-monitors";
      }
    ];
    events = {
      before-sleep = "echo 'before-sleep hook'; if ${pkgs.procps}/bin/pgrep swaylock; then echo 'already locked'; else echo 'locking!' && ${pkgs.swaylock-effects}/bin/swaylock -f --grace=0; fi";
      after-resume = "echo 'after-resume hook'; ${pkgs.systemd}/bin/systemctl --user kill -sSIGHUP kanshi";
    };
  };
}
