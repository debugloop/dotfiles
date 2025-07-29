{flake, ...}: {
  imports = [
    ./hardware-configuration.nix
    flake.nixosModules.common
    flake.nixosModules.class-server
    flake.nixosModules.service-caddy
    flake.nixosModules.service-factorio
    flake.nixosModules.service-grafana
    flake.nixosModules.service-grocy
    flake.nixosModules.service-matrix
    flake.nixosModules.service-miniflux
    flake.nixosModules.service-prometheus
    flake.nixosModules.service-restic-rest
  ];

  networking = {
    nameservers = [
      "46.38.225.230"
      "46.38.252.230"
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
