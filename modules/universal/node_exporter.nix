_: {
  flake.modules.nixos.node_exporter = {config, ...}: {
    services.prometheus.exporters.node = {
      enable = true;
      enabledCollectors = ["systemd"];
    };

    services.prometheus.scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = ["${config.networking.hostName}:${toString config.services.prometheus.exporters.node.port}"];
            labels.host = config.networking.hostName;
          }
        ];
      }
    ];
  };
}
