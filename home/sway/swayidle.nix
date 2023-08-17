{ pkgs, ... }:

{
  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 10;
        command = "if ${pkgs.procps}/bin/pgrep swaylock; then echo '10s passed and already locked, turning of display' && ${pkgs.sway}/bin/swaymsg 'output * power off' &> /dev/null; fi";
        resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * power on' &> /dev/null";
      }
      {
        timeout = 240;
        command = "echo '4min passed'; if ${pkgs.procps}/bin/pgrep swaylock; then echo 'already locked'; else echo 'locking!' && ${pkgs.swaylock-effects}/bin/swaylock -f; fi";
      }
      {
        timeout = 300;
        command = "echo '5min passed, turning display off' && ${pkgs.sway}/bin/swaymsg 'output * power off' &> /dev/null";
        resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * power on' &> /dev/null";
      }
    ];
    events = [
      {
        event = "before-sleep";
        command = "if ${pkgs.procps}/bin/pgrep swaylock; then echo 'already locked'; else ${pkgs.swaylock-effects}/bin/swaylock -f --grace 0; fi";
      }
      {
        event = "after-resume";
        command = "${pkgs.sway}/bin/swaymsg 'output * power on' &> /dev/null && systemctl --user kill -sSIGHUP kanshi";
      }
    ];
  };
}
