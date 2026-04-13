let
  basicauthHash = import ./_basicauth.nix;
in
  _: {
    flake.modules.nixos.rqbit = {
      config,
      pkgs,
      inputs,
      ...
    }: {
      networking.wg-quick.interfaces.mullvad.configFile = "${config.age.secrets.mullvad-conf.path}";
      age.secrets.mullvad-conf.file = inputs.self + "/secrets/mullvad.conf.age";

      nixpkgs.overlays = [
        (self: super: {
          rqbit = super.rqbit.overrideAttrs (_old: rec {
            version = "9.0.0-beta.2";
            src = pkgs.fetchFromGitHub {
              owner = "ikatson";
              repo = "rqbit";
              rev = "v9.0.0-beta.2";
              hash = "sha256-48gWvfPsmsQAifxHHCNpWYE8cGxdA4I4c27yqykSNK0=";
            };
            cargoDeps = self.rustPlatform.fetchCargoVendor {
              inherit src;
              hash = "sha256-cOB4hgwGIT6NzNI45cp755ysABtXVXQ45cweJPqKdWU=";
            };
          });
        })
      ];
      environment.systemPackages = with pkgs; [
        rqbit
      ];

      systemd.services.rqbit = {
        requires = ["wg-quick-mullvad.service"];
        wantedBy = ["multi-user.target"];
        path = with pkgs; [
          rqbit
        ];
        serviceConfig = {
          Description = "Run rqbit download manager.";
          Type = "simple";
          User = "danieln";
          ExecStart = "${pkgs.rqbit}/bin/rqbit --bind-device=mullvad --disable-upnp-port-forward --disable-lsd server start /home/danieln/downloads";
        };
      };

      environment.persistence."/nix/persist".users.danieln = {
        directories = [
          ".local/share/com.rqbit.session"
        ];
      };

      services.caddy.virtualHosts."dl.danieln.de".extraConfig = ''
        basicauth * {
          ${basicauthHash}
        }
        reverse_proxy localhost:3030
      '';
    };
  }
