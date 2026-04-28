{
  name,
  workspace,
  mainUser,
  ipAddress,
  tapId,
  mac,
  inputs,
  vsockCid,
  extraInit ? "",
}: {pkgs, ...}: {
  imports = [inputs.home-manager.nixosModules.home-manager];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${mainUser} = {
      imports = [./_microvm-home.nix];
      home.username = mainUser;
      home.homeDirectory = "/home/${mainUser}";
      microvm.extraInit = extraInit;
      microvm.workspace = workspace;
    };
  };

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

  services.resolved.enable = true;

  # Match host UID/GID so virtiofs-shared files have correct ownership
  users.groups.${mainUser}.gid = 1000;
  users.users.${mainUser} = {
    uid = 1000;
    group = mainUser;
    isNormalUser = true;
    shell = pkgs.fish;
    openssh.authorizedKeys.keyFiles = [
      (inputs.self + "/keys/auth/lusus.pub")
      (inputs.self + "/keys/auth/simmons.pub")
    ];
  };

  networking = {
    hostName = name;
    useDHCP = false;
    useNetworkd = true;
    tempAddresses = "disabled";
    nameservers = [
      "8.8.8.8"
      "1.1.1.1"
    ];
    firewall.enable = false;
  };

  systemd = {
    network = {
      enable = true;
      networks."10-e" = {
        matchConfig.Name = "e*";
        addresses = [{Address = "${ipAddress}/24";}];
        routes = [{Gateway = "192.168.83.1";}];
      };
    };
    settings.Manager = {
      # Fast VM shutdown
      DefaultTimeoutStopSec = "5s";
    };
    # Fix shutdown hang: umount lives in /nix/store, so disable default deps
    # on the store mount unit to avoid deadlock during shutdown (microvm.nix#170)
    mounts = [
      {
        what = "store";
        where = "/nix/store";
        overrideStrategy = "asDropin";
        unitConfig.DefaultDependencies = false;
      }
    ];
  };

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
        source = "/home/${mainUser}/.claude";
        mountPoint = "/home/${mainUser}/.claude";
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
