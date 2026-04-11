let
  matrixProxy = ''
    reverse_proxy /_matrix/* localhost:8008
    reverse_proxy /_synapse/client/* localhost:8008
  '';
in { ... }: {
  flake.modules.nixos.service_matrix = {...}: {
    services.matrix-synapse = {
      enable = true;
      settings = {
        server_name = "bugpara.de";
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

    environment.persistence."/nix/persist" = {
      directories = [
        "/var/lib/matrix-synapse"
      ];
    };

    services.caddy.virtualHosts."bugpara.de".extraConfig = ''
      redir / https://danieln.de permanent
      ${matrixProxy}'';

    services.caddy.virtualHosts."matrix.bugpara.de".extraConfig = ''
      ${matrixProxy}'';

    services.caddy.virtualHosts."bugpara.de:8448".extraConfig = ''
      reverse_proxy /_matrix/* localhost:8008
    '';
  };
}
