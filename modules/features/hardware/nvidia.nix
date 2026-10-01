_: {
  flake.modules.nixos.nvidia = _: {
    services.xserver.videoDrivers = ["nvidia"];
    hardware.nvidia.open = true;
  };
}
