_: {
  flake.modules.nixos.storagebox_mount = {
    config,
    lib,
    pkgs,
    ...
  }: let
    mountpoint = "/mnt/storagebox";
  in {
    options.storagebox_mount.enable = lib.mkEnableOption "SSHFS mount of Hetzner StorageBox";

    config = lib.mkIf config.storagebox_mount.enable {
      programs.fuse.userAllowOther = true;
      environment.systemPackages = [pkgs.sshfs pkgs.fuse3];

      systemd.tmpfiles.rules = [
        "d ${mountpoint} 0755 root root -"
        "d /root/.ssh 0700 root root -"
        "f /root/.ssh/known_hosts 0644 root root -"
      ];

      systemd.services.storagebox-sshfs = {
        description = "Storage Box SSHFS mount";
        after = ["network-online.target"];
        wants = ["network-online.target"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          Type = "simple";
          ExecStart = ''
            ${pkgs.sshfs}/bin/sshfs -f \
              -p 23 \
              -o IdentityFile=/etc/ssh/ssh_host_ed25519_key \
              -o IdentitiesOnly=yes \
              -o PreferredAuthentications=publickey \
              -o PasswordAuthentication=no \
              -o StrictHostKeyChecking=accept-new \
              -o UserKnownHostsFile=/root/.ssh/known_hosts \
              -o ServerAliveInterval=15 \
              -o ServerAliveCountMax=3 \
              -o reconnect \
              -o allow_other \
              -o uid=0 \
              -o gid=0 \
              -o umask=077 \
              -o noatime \
              ${config.backup.storagebox.user}@${config.backup.storagebox.host}:. ${mountpoint}
          '';
          ExecStop = "${pkgs.fuse3}/bin/fusermount3 -u ${mountpoint}";
          Restart = "on-failure";
          RestartSec = 2;
        };
      };
    };
  };
}
