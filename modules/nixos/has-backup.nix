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
      "home/danieln/.cache"
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
