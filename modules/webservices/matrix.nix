let
  matrixProxy = ''
    reverse_proxy /_matrix/* localhost:8008
    reverse_proxy /_synapse/client/* localhost:8008
  '';
in
  _: {
    flake.nixosModules.matrix = _: {
      services = {
        matrix-synapse = {
          enable = true;
          settings = {
            server_name = "bugpara.de";
            database = {
              name = "sqlite3";
            };
          };
        };

        caddy.virtualHosts = {
          "bugpara.de".extraConfig = ''
            redir / https://danieln.de permanent
            ${matrixProxy}'';
          "matrix.bugpara.de".extraConfig = ''
            ${matrixProxy}'';
          "bugpara.de:8448".extraConfig = ''
            reverse_proxy /_matrix/* localhost:8008
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
          "/var/lib/matrix-synapse"
        ];
      };
    };
  }
