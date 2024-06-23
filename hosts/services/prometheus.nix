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
}
