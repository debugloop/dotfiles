{ config, ... }:

{
  services.miniflux = {
    enable = true;
    adminCredentialsFile = "${config.age.secrets.miniflux.path}";
    config = {
      LISTEN_ADDR = "localhost:8081";
    };
  };

  age.secrets.miniflux.file = ../../secrets/miniflux.age;

  services.caddy.virtualHosts."rss.danieln.de".extraConfig = ''
    reverse_proxy http://localhost:8081
  ''; 

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/postgresql"
    ];
  };
}
