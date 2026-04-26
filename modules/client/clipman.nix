_: {
  flake.modules.homeManager.clipman = _: {
    services.clipman = {
      enable = true;
      systemdTarget = "graphical-session.target";
    };
  };
}
