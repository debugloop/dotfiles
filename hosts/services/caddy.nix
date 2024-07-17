{hostname, ...}: {
  services.caddy = {
    enable = true;
    virtualHosts."${hostname}.danieln.de".extraConfig = ''
      metrics /metrics
    '';
  };

  networking.firewall.allowedTCPPorts = [80 443];

  services.caddy.virtualHosts."danieln.de".extraConfig = ''
    respond "brb!"
  '';

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/caddy"
    ];
  };
}
