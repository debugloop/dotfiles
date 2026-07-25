_: {
  flake.modules.nixos.caddy = {config, ...}: {
    services = {
      caddy = {
        enable = true;
        globalConfig = ''
          metrics {
            per_host
          }
        '';
        virtualHosts = {
          # "${config.networking.hostName}.bugpara.de".extraConfig = ''
          #   metrics /metrics
          # '';
          # "${config.networking.hostName}.danieln.de".extraConfig = ''
          #   metrics /metrics
          # '';
          # "danieln.de".extraConfig = ''
          #   respond "brb!"
          # '';
        };
      };

      prometheus.scrapeConfigs = [
        {
          job_name = "caddy";
          scheme = "https";
          static_configs = [
            {
              targets = [config.networking.fqdn];
              labels.host = config.networking.hostName;
            }
          ];
        }
      ];
    };

    networking.firewall.allowedTCPPorts = [80 443];

    environment.persistence."/nix/persist" = {
      directories = [
        "/var/lib/caddy"
      ];
    };
  };
}
