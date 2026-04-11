{
  name,
  workspace,
  ipAddress,
  tapId,
  mac,
  inputs,
  vsockCid,
  extraInit ? "",
}: {
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [inputs.home-manager.nixosModules.home-manager];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.danieln = {
      imports = [./_microvm-home.nix];
      microvm.extraInit = extraInit;
      microvm.workspace = workspace;
    };
  };

  networking.hostName = name;

  system.stateVersion = "25.11";

  programs.fish.enable = true;

  services.openssh = {
    enable = true;
    hostKeys = [
      {
        path = "/etc/ssh/host-keys/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  # Match host UID/GID so virtiofs-shared files have correct ownership
  users.groups.danieln.gid = 1000;
  users.users.danieln = {
    uid = 1000;
    group = "danieln";
    isNormalUser = true;
    shell = pkgs.fish;
    openssh.authorizedKeys.keyFiles = [
      ../../../keys/auth/lusus.pub
      ../../../keys/auth/simmons.pub
      ../../../keys/auth/hyperion.pub
    ];
  };

  services.resolved.enable = true;
  networking.useDHCP = false;
  networking.useNetworkd = true;
  networking.tempAddresses = "disabled";
  systemd.network.enable = true;
  systemd.network.networks."10-e" = {
    matchConfig.Name = "e*";
    addresses = [{Address = "${ipAddress}/24";}];
    routes = [{Gateway = "192.168.83.1";}];
  };
  networking.nameservers = ["8.8.8.8" "1.1.1.1"];

  # No external exposure — we're behind host NAT
  networking.firewall.enable = false;

  systemd.settings.Manager = {
    # Fast VM shutdown
    DefaultTimeoutStopSec = "5s";
  };

  # Fix shutdown hang: umount lives in /nix/store, so disable default deps
  # on the store mount unit to avoid deadlock during shutdown (microvm.nix#170)
  systemd.mounts = [
    {
      what = "store";
      where = "/nix/store";
      overrideStrategy = "asDropin";
      unitConfig.DefaultDependencies = false;
    }
  ];

  microvm = {
    hypervisor = "cloud-hypervisor";
    vsock.cid = vsockCid;
    vcpu = 8;
    mem = 8192;
    socket = "control.socket";

    # Writable overlay so nix-daemon and home-manager activation work inside VM
    writableStoreOverlay = "/nix/.rw-store";

    volumes = [
      {
        mountPoint = "/var";
        image = "var.img";
        size = 8192;
      }
    ];

    shares = [
      {
        proto = "virtiofs";
        tag = "ro-store";
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
      }
      {
        proto = "virtiofs";
        tag = "ssh-keys";
        source = "${workspace}/ssh-host-keys";
        mountPoint = "/etc/ssh/host-keys";
      }
      {
        proto = "virtiofs";
        tag = "claude-credentials";
        source = "/home/danieln/.claude";
        mountPoint = "/home/danieln/.claude";
      }
      {
        proto = "virtiofs";
        tag = "workspace";
        source = workspace;
        mountPoint = workspace;
      }
    ];

    interfaces = [
      {
        type = "tap";
        id = tapId;
        inherit mac;
      }
    ];
  };
}
