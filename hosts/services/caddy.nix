{ hostname, ... }:

{
  services.caddy = {
    enable = true;
    virtualHosts."${hostname}.danieln.de".extraConfig = ''
      metrics /metrics
    ''; 
    virtualHosts."grafana.danieln.de".extraConfig = ''
      reverse_proxy http://localhost:3000
    ''; 
    virtualHosts."prometheus.danieln.de".extraConfig = ''
      basicauth * {
        danieln $2a$14$BHCi0dM1slv2JypVYffCZ.LAbPH8x3037LwVlRaxySIppSPR1Ixlm
      }
      reverse_proxy http://localhost:9090
    ''; 
    virtualHosts."vorrat.danieln.de".extraConfig = ''
      reverse_proxy http://localhost:8080
    ''; 
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/caddy"
    ];
  };
}
