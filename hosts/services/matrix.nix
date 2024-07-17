{config, ...}: {
  services = {
    heisenbridge = {
      enable = true;
      owner = "@d:bugpara.de";
      homeserver = "http://localhost:8008";
    };
    matrix-synapse = {
      enable = true;
      settings = {
        app_service_config_files = [
          "/var/lib/heisenbridge/registration.yml"
        ];
        server_name = "bugpara.de";
        database = {
          name = "sqlite3";
        };
      };
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      8448
    ];
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/heisenbridge"
      "/var/lib/matrix-synapse"
    ];
  };

  services.caddy.virtualHosts."bugpara.de".extraConfig = ''
    redir / https://danieln.de permanent
    reverse_proxy /_matrix/* localhost:8008
    reverse_proxy /_synapse/client/* localhost:8008
  '';

  services.caddy.virtualHosts."matrix.bugpara.de".extraConfig = ''
    reverse_proxy /_matrix/* localhost:8008
    reverse_proxy /_synapse/client/* localhost:8008
  '';

  services.caddy.virtualHosts."bugpara.de:8448".extraConfig = ''
    reverse_proxy /_matrix/* localhost:8008
  '';
}
