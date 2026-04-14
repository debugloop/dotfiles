_: {
  flake.modules.nixos.printing = {config, ...}: {
    users.users.${config.mainUser}.extraGroups = ["lp"];
    services.printing.enable = true;
  };
}
