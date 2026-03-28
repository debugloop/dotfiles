{
  flake,
  inputs,
  config,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    flake.nixosModules.hetzner
    flake.nixosModules.has-backup
    inputs.disko.nixosModules.disko
    ./disko.nix
    flake.nixosModules.common
    flake.nixosModules.class-server
    # flake.nixosModules.service-cache
    # flake.nixosModules.service-caddy
    # flake.nixosModules.service-factorio
    # flake.nixosModules.service-grafana
    # flake.nixosModules.service-grocy
    # flake.nixosModules.service-jellyfin
    # flake.nixosModules.service-matrix
    flake.nixosModules.service-miniflux
    # flake.nixosModules.service-prometheus
    # flake.nixosModules.service-rqbit
    # flake.nixosModules.service-woodpecker
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "roshar";

  hetzner = {
    enable = true;
    serverType = "cx23";
    location = "nbg1";
    image = "debian-12";
    sshKeyNames = ["hyperion" "simmons"];
  };

  networking.useDHCP = true;
  services.openssh.enable = true;
  programs.fuse.userAllowOther = true;

  environment.systemPackages = [pkgs.sshfs pkgs.fuse3];
  systemd.tmpfiles.rules = [
    "d /mnt/storagebox 0755 root root -"
    "d /root/.ssh 0700 root root -"
    "f /root/.ssh/known_hosts 0644 root root -"
  ];

  systemd.services.storagebox-sshfs = let
    storageBox = import ./storagebox.nix;
  in {
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
          ${storageBox.user}@${storageBox.host}:. /mnt/storagebox
      '';
      ExecStop = "${pkgs.fuse3}/bin/fusermount3 -u /mnt/storagebox";
      Restart = "on-failure";
      RestartSec = 2;
    };
  };
  system.stateVersion = "24.11";

  users.users.root.openssh.authorizedKeys.keys =
    map
    (name: builtins.readFile (../../keys/auth + "/${name}.pub"))
    config.hetzner.sshKeyNames;
}
