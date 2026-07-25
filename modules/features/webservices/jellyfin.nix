_: {
  flake.modules.nixos.jellyfin = _: {
    services = {
      jellyfin.enable = true;

      caddy.virtualHosts."jellyfin.bugpara.de".extraConfig = ''
        reverse_proxy localhost:8096
      '';
    };

    environment.persistence."/nix/persist" = {
      directories = [
        "/var/lib/jellyfin"
        "/var/cache/jellyfin"
      ];
    };
  };
}
