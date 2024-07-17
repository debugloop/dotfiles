{
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  boot = {
    initrd = {
      availableKernelModules = ["ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk"];
      kernelModules = [];
    };
    kernelModules = [];
    extraModulePackages = [];
    kernelPackages = pkgs.linuxPackages_latest;
    tmp.useTmpfs = true;
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
      };
    };
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/CC8C-98BB";
      fsType = "vfat";
    };
    "/nix" = {
      device = "/dev/disk/by-uuid/97c78d7f-8a6c-4e6c-9957-4c51bc31b040";
      fsType = "xfs";
    };
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = ["defaults" "size=1G" "mode=755"];
    };
  };

  swapDevices = [
    {label = "swap";}
  ];

  networking = {
    nameservers = [
      "46.38.225.230"
      "46.38.252.230"
    ];
    useDHCP = false;
    interfaces.ens3 = {
      ipv4.addresses = [
        {
          address = "37.120.188.134";
          prefixLength = 22;
        }
      ];
      ipv6.addresses = [
        {
          address = "2a03:4000:6:b08a::";
          prefixLength = 64;
        }
      ];
    };
    defaultGateway = {
      address = "37.120.188.1";
      interface = "ens3";
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "ens3";
    };
  };
}
