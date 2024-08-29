{
  inputs,
  lib,
  ...
}: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.danieln = import ../../home/headless.nix;
    extraSpecialArgs = {
      inherit inputs;
    };
  };

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
