_: {
  flake.modules.nixos.auto_cleanup = _: {
    programs.nh.clean = {
      enable = true;
      dates = "*-*-* 06:00:00";
      extraArgs = "--keep 2 --keep-since 2d";
    };
  };
}
