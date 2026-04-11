{top, ...}: {
  imports = with top.modules.nixos; [
    common_base
    common_backup_persisted
    common_hetzner
    common_impermanence
    common_nix
    common_software
    common_tailscale
    server_base
    service_cache
    service_caddy
    service_grafana
    service_grocy
    service_matrix
    service_miniflux
    service_prometheus
    service_jellyfin
    service_rqbit
    service_woodpecker
    ./hardware-configuration.nix
  ];

  system.stateVersion = "22.11";

  networking = {
    nameservers = [
      "9.9.9.9"
      "149.112.112.112"
      "2620:fe::fe"
      "2620:fe::9"
    ];
    useDHCP = false;
    interfaces.ens3 = {
      ipv4.addresses = [
        {
          address = "37.120.188.134";
          prefixLength = 22;
        }
      ];
      ipv6.addresses = [
        {
          address = "2a03:4000:6:b08a::";
          prefixLength = 64;
        }
      ];
    };
    defaultGateway = {
      address = "37.120.188.1";
      interface = "ens3";
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "ens3";
    };
  };
}
