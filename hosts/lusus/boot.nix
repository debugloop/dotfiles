{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  fileSystems = {
  "/nix" =
    { device = "/dev/disk/by-uuid/2bbe58f6-c736-4207-8646-05b07fd024f4";
      fsType = "xfs";
    };

  "/boot" =
    { device = "/dev/disk/by-uuid/D7EE-6599";
      fsType = "vfat";
    };
  };


  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "usb_storage" "sd_mod" ];
      kernelModules = [ "usb_storage" "i2c-dev" ];
      luks.devices.crypt = {
        device = "/dev/disk/by-uuid/d31e511f-f385-4993-9437-619e9501f535";
        allowDiscards = true;
      };
    };
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = false;
      };
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback.out ];
    tmp.useTmpfs = true;
  };

  swapDevices = [ ];
}
