_: {
  flake.modules.nixos.caddy = {
    config,
    lib,
    ...
  }: {
    options.webservices.basicauth = lib.mkOption {
      type = lib.types.str;
      default = "danieln $2a$14$BHCi0dM1slv2JypVYffCZ.LAbPH8x3037LwVlRaxySIppSPR1Ixlm";
      description = "Shared Caddy basicauth bcrypt hash line.";
    };

    config = {
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
  };
}
