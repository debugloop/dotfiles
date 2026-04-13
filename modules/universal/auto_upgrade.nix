_: {
  flake.nixosModules.auto_upgrade = _: {
    system.autoUpgrade = {
      enable = true;
      persistent = false;
      flake = "git+https://codeberg.org/debugloop/dotfiles";
      allowReboot = true;
    };
  };
}
