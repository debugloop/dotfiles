_: {
  flake.modules.nixos.maintenance = _: {
    programs.nh.clean = {
      enable = true;
      dates = "*-*-* 06:00:00";
      extraArgs = "--keep 2 --keep-since 2d";
    };

    system.autoUpgrade = {
      enable = true;
      persistent = false;
      flake = "git+https://codeberg.org/debugloop/dotfiles";
      allowReboot = true;
    };
  };
}
