_: {
  flake.modules.nixos.node_exporter = _: {
    services.prometheus.exporters.node = {
      enable = true;
      enabledCollectors = ["systemd"];
    };
  };
}
