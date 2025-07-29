{
  config,
  hostName,
  ...
}: {
  age.secrets.restic_password = {
    file = ../../secrets/restic_password.age;
    owner = "danieln";
  };

  services.restic.backups.daily = {
    initialize = true;
    passwordFile = config.age.secrets.restic_password.path;
    paths = ["/nix/persist"];
    exclude = [
      "var/log"
      "home/danieln/go" # golang cache
      "home/danieln/scratch" # random repos
      "home/danieln/downloads" # random crap
      "home/danieln/.local/share/Steam" # steam and its games
      "home/danieln/.cache" # spotify downloads
      "home/danieln/.thunderbird" # heaps of email
      "home/danieln/.config/google-chrome" # browser is covered by sync
      "home/danieln/.config/Slack" # slack syncs itself
      "home/danieln/.mozilla" # nothing that firefox sync won't cover
      "home/danieln/.config/TeamSpeak" # nothing of value
      "home/danieln/code/*/.cache" # direnv caches etc
      # huge repo that I don't care about
      "home/danieln/code/qmk"
      "home/danieln/code/qmk_firmware"
      "home/danieln/code/Garmin"
    ];
    repository = "rest:http://hyperion.squirrel-emperor.ts.net:8000/${hostName}";
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
}
