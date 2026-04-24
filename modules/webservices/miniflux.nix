_: {
  flake.modules.nixos.miniflux = {
    config,
    inputs,
    ...
  }: {
    services.miniflux = {
      enable = true;
      adminCredentialsFile = "${config.age.secrets.miniflux.path}";
      config = {
        LISTEN_ADDR = "localhost:8081";
      };
    };

    age.secrets.miniflux.file = inputs.self + "/secrets/miniflux.age";

    services.caddy.virtualHosts."rss.bugpara.de".extraConfig = ''
      reverse_proxy localhost:8081
    '';

    environment.persistence."/nix/persist" = {
      directories = [
        "/var/lib/postgresql"
      ];
    };
  };
}
