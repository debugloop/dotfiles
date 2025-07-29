{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot = {
    initrd = {
      availableKernelModules = ["nvme" "xhci_pci" "usb_storage" "sd_mod"];
      kernelModules = ["usb_storage" "amdgpu" "i2c-dev"];
      luks.devices.crypt = {
        device = "/dev/disk/by-uuid/4eb11486-bcd4-46aa-857c-ff6545dcd90e";
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
    kernelModules = ["kvm-amd"];
    kernelParams = ["amdgpu.sg_display=0"];
    extraModulePackages = with config.boot.kernelPackages; [v4l2loopback.out];
    tmp.useTmpfs = true;
  };

  fileSystems = {
    "/nix" = {
      device = "/dev/disk/by-uuid/f3396211-db7a-4d64-86f9-9b5fb36de182";
      fsType = "xfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/F436-A8DB";
      fsType = "vfat";
    };
  };

  swapDevices = [];
}
