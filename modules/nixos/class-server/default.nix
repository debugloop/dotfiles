{lib, ...}: {
  services = {
    prometheus.exporters = {
      node = {
        enable = true;
        enabledCollectors = ["systemd"];
      };
    };
    tailscale = {
      useRoutingFeatures = lib.mkForce "server";
      extraUpFlags = [
        "--advertise-exit-node"
      ];
    };
  };

  system.autoUpgrade = {
    enable = true;
    persistent = false;
    flake = "github:debugloop/dotfiles";
    allowReboot = true;
  };
}
