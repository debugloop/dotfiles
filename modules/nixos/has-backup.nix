{
  config,
  hostName,
  inputs,
  lib,
  ...
}: let
  storageBoxFile = ../../hosts/${hostName}/storagebox.nix;
  storageBox = if builtins.pathExists storageBoxFile then import storageBoxFile else { host = ""; user = ""; };
  storageBoxHostAlias = "storagebox-${hostName}";
in {
  imports = [
    inputs.agenix.nixosModules.default
  ];

  assertions = [
    {
      assertion = builtins.pathExists storageBoxFile;
      message = "has-backup requires ${toString storageBoxFile}. Run: nix run .#hetzner-storagebox -- apply";
    }
  ];

  age.identityPaths = lib.mkDefault ["/etc/ssh/ssh_host_ed25519_key"];

  programs.ssh.extraConfig = ''
    Host ${storageBoxHostAlias}
      HostName ${storageBox.host}
      User ${storageBox.user}
      Port 23
      IdentityFile /etc/ssh/ssh_host_ed25519_key
      IdentitiesOnly yes
      StrictHostKeyChecking accept-new
      UserKnownHostsFile /root/.ssh/known_hosts
      ServerAliveInterval 15
      ServerAliveCountMax 3
      LogLevel ERROR
  '';

  systemd.tmpfiles.rules = [
    "d /root/.ssh 0700 root root -"
    "f /root/.ssh/known_hosts 0644 root root -"
  ];

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
      "var/lib/flatpak"
      "var/lib/docker"
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
      "home/danieln/.var" # flatpak data
      "home/danieln/code/*/.cache" # direnv caches etc
      # huge repo that I don't care about
      "home/danieln/code/qmk"
      "home/danieln/code/qmk_firmware"
      "home/danieln/code/Garmin"
    ];
    repository = "sftp:${storageBoxHostAlias}:restic";
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
