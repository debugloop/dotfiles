_: {
  flake.nixosModules.service_grocy = _: {
    services = {
      grocy = {
        enable = true;
        hostName = "https://vorrat.danieln.de";
        nginx.enableSSL = false;
        settings = {
          currency = "EUR";
          culture = "de";
          calendar.firstDayOfWeek = 1;
        };
      };

      nginx.defaultHTTPListenPort = 8080;

      caddy.virtualHosts."vorrat.danieln.de".extraConfig = ''
        reverse_proxy localhost:8080
      '';
    };

    environment.persistence."/nix/persist" = {
      directories = [
        "/var/lib/grocy"
      ];
    };
  };
}
