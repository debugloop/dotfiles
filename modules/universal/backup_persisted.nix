_: {
  flake.modules.nixos.backup_persisted = {
    config,
    inputs,
    lib,
    ...
  }: let
    cfg = config.backup;
    hostname = config.networking.hostName;
    storageBoxHostAlias = "storagebox-${hostname}";
  in {
    imports = [inputs.agenix.nixosModules.default];

    options.backup = {
      enable = lib.mkEnableOption "restic backup of /nix/persist";
      storagebox = {
        host = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Hostname of the Hetzner StorageBox subaccount.";
        };
        user = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Username for the Hetzner StorageBox subaccount.";
        };
      };
      exclude = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Paths relative to /nix/persist to exclude from the daily restic backup.";
      };
    };

    config = lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = cfg.storagebox.host != "" && cfg.storagebox.user != "";
          message = ''backup.storagebox.host and backup.storagebox.user must be set when backup is enabled for host "${hostname}".'';
        }
      ];

      age.identityPaths = lib.mkDefault ["/etc/ssh/ssh_host_ed25519_key"];

      programs.ssh.extraConfig = ''
        Host ${storageBoxHostAlias}
          HostName ${cfg.storagebox.host}
          User ${cfg.storagebox.user}
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
        file = inputs.self + "/secrets/restic_password.age";
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
