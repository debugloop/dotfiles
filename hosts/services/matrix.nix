{ config, ... }:

{
  services.matrix-synapse = {
    enable = true;
    settings = {
      server_name = "danieln.de";
      database = {
        name = "sqlite3";
      };
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      8448
    ];
  };

  services.caddy.virtualHosts."matrix.danieln.de".extraConfig = ''
    reverse_proxy /_matrix/* localhost:8008
    reverse_proxy /_synapse/client/* localhost:8008
  ''; 

  services.caddy.virtualHosts."danieln.de:8448".extraConfig = ''
    reverse_proxy /_matrix/* localhost:8008
  ''; 
}
