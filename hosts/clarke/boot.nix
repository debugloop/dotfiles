{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  fileSystems = {
    "/nix" =
      {
        device = "/dev/disk/by-uuid/e16b1c19-95dc-4119-a535-a4e7baa330c4";
        fsType = "xfs";
      };

    "/boot" =
      {
        device = "/dev/disk/by-uuid/819E-6D65";
        fsType = "vfat";
      };
  };

  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "sd_mod" ];
      kernelModules = [ "usb_storage" "i2c-dev" ];
      luks.devices.crypt = {
        device = "/dev/disk/by-uuid/8be92b1e-0907-4ae0-a000-eb8cc250fe8d";
        allowDiscards = true;
      };
    };
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
      };
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    tmp.useTmpfs = true;
  };

  swapDevices = [ ];
}
