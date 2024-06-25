{ hostname, ... }:

{
  services.prometheus = {
    enable = true;
    extraFlags = [
      "--storage.tsdb.retention.size=64GB"
    ];
    globalConfig = {
      scrape_interval = "15s";
      evaluation_interval = "15s";
    };
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
        {
          targets = [
            "localhost:9100"
          ];
          labels = {
            host = "${hostname}";
          };
        }
        ];
      }
      {
        job_name = "prometheus";
        static_configs = [
        {
          targets = [
            "localhost:9090"
          ];
          labels = {
            host = "${hostname}";
          };
        }
        ];
      }
      {
        job_name = "grafana";
        static_configs = [
        {
          targets = [
            "localhost:3000"
          ];
          labels = {
            host = "${hostname}";
          };
        }
        ];
      }
      {
        job_name = "caddy";
        scheme = "https";
        static_configs = [
        {
          targets = [
            "hyperion.danieln.de"
          ];
          labels = {
            host = "${hostname}";
          };
        }
        ];
      }
    ];
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/prometheus2"
    ];
  };

  services.caddy.virtualHosts."prometheus.danieln.de".extraConfig = ''
    basicauth * {
      danieln $2a$14$BHCi0dM1slv2JypVYffCZ.LAbPH8x3037LwVlRaxySIppSPR1Ixlm
    }
    reverse_proxy localhost:9090
  ''; 
}
