{ hostname, ... }:

{
  services.prometheus = {
    enable = true;
    extraFlags = [
      "--storage.tsdb.retention.size=64GB"
    ];
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
        {
          targets = [
            "localhost:9100"
          ];
          labels = {
            alias = "${hostname}";
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
    reverse_proxy http://localhost:9090
  ''; 
}
