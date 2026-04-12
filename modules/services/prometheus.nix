let
  basicauthHash = import ./_basicauth.nix;
in
  _: {
    flake.nixosModules.service_prometheus = {config, ...}: {
      services.prometheus = {
        enable = true;
        extraFlags = ["--storage.tsdb.retention.size=64GB"];
        globalConfig = {
          scrape_interval = "15s";
          evaluation_interval = "15s";
        };
        scrapeConfigs = [
          {
            job_name = "node";
            static_configs = [
              {
                targets = ["localhost:9100"];
                labels.host = config.networking.hostName;
              }
            ];
          }
          {
            job_name = "prometheus";
            static_configs = [
              {
                targets = ["localhost:9090"];
                labels.host = config.networking.hostName;
              }
            ];
          }
          {
            job_name = "grafana";
            static_configs = [
              {
                targets = ["localhost:3000"];
                labels.host = config.networking.hostName;
              }
            ];
          }
          {
            job_name = "caddy";
            scheme = "https";
            static_configs = [
              {
                targets = ["hyperion.danieln.de"];
                labels.host = config.networking.hostName;
              }
            ];
          }
          {
            job_name = "restic-server";
            static_configs = [
              {
                targets = ["localhost:8000"];
                labels.host = config.networking.hostName;
              }
            ];
          }
        ];
      };

      environment.persistence."/nix/persist".directories = ["/var/lib/prometheus2"];

      backup.exclude = ["var/lib/prometheus2"];

      services.caddy.virtualHosts."prometheus.danieln.de".extraConfig = ''
        basicauth * {
          ${basicauthHash}
        }
        reverse_proxy localhost:9090
      '';
    };
  }
