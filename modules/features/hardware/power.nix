_: {
  flake.modules.nixos.power = _: {
    services = {
      tuned.enable = true;
      upower.enable = true;
    };
  };
}
