{...}: {
  services = {
    prometheus.exporters = {
      node = {
        enable = true;
        enabledCollectors = ["systemd"];
      };
    };
  };

  system.autoUpgrade = {
    enable = true;
    persistent = false;
    flake = "github:debugloop/dotfiles";
    allowReboot = true;
  };

  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      dates = "Mon *-*-* 06:00:00";
      extraArgs = "--keep 5 --keep-since 3d";
    };
  };
}
