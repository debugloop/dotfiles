{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    restic
  ];

  services.restic.backups.daily = {
    initialize = true;
    rcloneConfigFile = config.age.secrets.restic_rclone_config.path;
    passwordFile = config.age.secrets.restic_password.path;
    paths = [ "/nix/persist" ];
    exclude = [
      "var/log"
      "home/danieln/scratch" # random repos
      "home/danieln/downloads" # random crap
      "home/danieln/.local/share/Steam" # steam and its games
      "home/danieln/.cache" # spotify downloads
      "home/danieln/.thunderbird" # heaps of email
      "home/danieln/.config/google-chrome" # browser is covered by sync
      "home/danieln/.config/Slack" # slack syncs itself
      "home/danieln/.mozilla" # nothing that firefox sync won't cover
      "home/danieln/.config/TeamSpeak" # nothing of value
    ];
    repository = "rclone:b2:danieln-backups/simmons";
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-yearly 10"
    ];
  };

  systemd.services.restic-backups-daily = {
    wants = [ "network.target" ];
    after = [ "network.target" ];
  };
}
