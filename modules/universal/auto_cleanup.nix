_: {
  flake.nixosModules.auto_cleanup = _: {
    programs.nh.clean = {
      enable = true;
      dates = "Mon *-*-* 06:00:00";
      extraArgs = "--keep 5 --keep-since 3d";
    };
  };
}
