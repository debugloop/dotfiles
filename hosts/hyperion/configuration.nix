{flake, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./services.nix
    flake.nixosModules.common
    flake.nixosModules.class-server
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
