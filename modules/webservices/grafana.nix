_: {
  flake.modules.nixos.grafana = {
    config,
    inputs,
    ...
  }: {
    services = {
      grafana = {
        enable = true;
        settings = {
          server = {
            root_url = "https://grafana.danieln.de/";
            domain = "grafana.danieln.de";
          };
          security = {
            admin_user = config.mainUser;
            admin_password = "$__file{${config.age.secrets.grafana.path}}";
            secret_key = "SW2YcwTIb9zpOOhoPsMm"; # previous hardcoded default, rotate for multiuser env
          };
        };
        provision = {
          enable = true;
          datasources.settings.datasources = [
            {
              name = "prometheus";
              type = "prometheus";
              url = "http://localhost:9090";
            }
          ];
        };
      };

      caddy.virtualHosts."grafana.danieln.de".extraConfig = ''
        reverse_proxy localhost:3000
      '';

      prometheus.scrapeConfigs = [
        {
          job_name = "grafana";
          static_configs = [
            {
              targets = ["localhost:${toString config.services.grafana.settings.server.http_port}"];
              labels.host = config.networking.hostName;
            }
          ];
        }
      ];
    };

    environment.persistence."/nix/persist" = {
      directories = [
        "/var/lib/grafana"
      ];
    };

    age.secrets.grafana = {
      file = inputs.self + "/secrets/grafana.age";
      mode = "770";
      owner = "grafana";
      group = "grafana";
    };
  };
}
