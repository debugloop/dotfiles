_: {
  flake.modules.nixos.scanning = {config, ...}: {
    hardware.sane.enable = true;
    users.users.${config.mainUser}.extraGroups = ["scanner"];
  };
}
