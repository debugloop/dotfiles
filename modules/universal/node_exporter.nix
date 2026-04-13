_: {
  flake.nixosModules.node_exporter = _: {
    services.prometheus.exporters.node = {
      enable = true;
      enabledCollectors = ["systemd"];
    };
  };
}
