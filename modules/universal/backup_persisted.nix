_: {
  flake.modules.nixos.backup_persisted = {
    config,
    inputs,
    lib,
    ...
  }: let
    cfg = config.backup;
    hostname = config.networking.hostName;
    storageBoxFile = ../hosts/${hostname}/_storagebox.nix;
    storageBox =
      if builtins.pathExists storageBoxFile
      then import storageBoxFile
      else {
        host = "";
        user = "";
      };
    storageBoxHostAlias = "storagebox-${hostname}";
  in {
    imports = [inputs.agenix.nixosModules.default];

    options.backup = {
      enable = lib.mkEnableOption "restic backup of /nix/persist";
      exclude = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Paths relative to /nix/persist to exclude from the daily restic backup.";
      };
    };

    config = lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = builtins.pathExists storageBoxFile;
          message = ''storagebox.nix not found for host "${hostname}". Run `nix run .#infra` to provision the host and generate credentials.'';
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
        exclude =
          [
            "var/log"
            "home/danieln/.cache"
          ]
          ++ cfg.exclude;
      };
    };
  };
}
