_: {
  flake.modules.nixos.matrix = _: {
    services = {
      matrix-continuwuity = {
        enable = true;
        settings.global = {
          server_name = "bugpara.de";
        };
      };

      caddy.virtualHosts = let
        matrixProxy = ''
          reverse_proxy /_matrix/* localhost:6167
          reverse_proxy /_synapse/client/* localhost:6167
        '';
      in {
        "bugpara.de".extraConfig = ''
          redir / https://danieln.de permanent

          handle /.well-known/matrix/server {
            header Content-Type application/json
            respond `{"m.server": "bugpara.de:8448"}`
          }

          handle /.well-known/matrix/client {
            header Content-Type application/json
            header Access-Control-Allow-Origin *
            respond `{"m.homeserver": {"base_url": "https://matrix.bugpara.de"}}`
          }

          ${matrixProxy}
        '';
        "matrix.bugpara.de".extraConfig = ''
          ${matrixProxy}
        '';
        "bugpara.de:8448".extraConfig = ''
          reverse_proxy /_matrix/* localhost:6167
        '';
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
        {
          directory = "/var/lib/matrix-continuwuity";
          user = "matrix-continuwuity";
          group = "matrix-continuwuity";
          mode = "0700";
        }
      ];
    };
  };
}
