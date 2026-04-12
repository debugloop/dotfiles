{...}: {
  flake.nixosModules.node_exporter = {...}: {
    services.prometheus.exporters.node = {
      enable = true;
      enabledCollectors = ["systemd"];
    };
  };
}
