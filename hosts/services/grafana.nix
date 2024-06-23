{ config, ... }:

{
  services.grafana = {
    enable = true;
    domain = "grafana.danieln.de";
    rootUrl = "https://grafana.danieln.de/";
    settings = {
      security = {
        admin_user = "danieln";
        admin_password = "$__file{${config.age.secrets.grafana.path}}";
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

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/grafana"
    ];
  };

  age = {
    secrets = {
      grafana = {
        file = ../../secrets/grafana.age;
        mode = "770";
        owner = "grafana";
        group = "grafana";
      };
    };
  };
}
