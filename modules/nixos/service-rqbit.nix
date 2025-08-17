{
  config,
  pkgs,
  ...
}: {
  networking.wg-quick.interfaces.mullvad.configFile = "${config.age.secrets.mullvad-conf.path}";
  age.secrets.mullvad-conf.file = ../../secrets/mullvad.conf.age;

  nixpkgs.overlays = [
    (self: super: {
      rqbit = super.rqbit.overrideAttrs (old: rec {
        version = "9.0.0-main";
        src = pkgs.fetchFromGitHub {
          owner = "ikatson";
          repo = "rqbit";
          rev = "62a9b624ad7da4d8af3abb9c7feb23a0c915adba";
          hash = "sha256-nNiBHH7obF4mhZLjlzXfMpejC4+Qleyk7Zy9iWGeZHw=";
        };
        cargoDeps = self.rustPlatform.fetchCargoVendor {
          inherit src;
          hash = "sha256-cy8buot0HKRpGKECaQC+8v7P4B+Y0IfKdFOmNIoA8UI=";
        };
      });
    })
  ];
  environment. systemPackages = with pkgs; [
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
      danieln $2a$14$BHCi0dM1slv2JypVYffCZ.LAbPH8x3037LwVlRaxySIppSPR1Ixlm
    }
    reverse_proxy localhost:3030
  '';
}
