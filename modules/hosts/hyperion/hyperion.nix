{
  self,
  inputs,
  ...
}: {
  flake = {
    sshForwardAgentHosts = ["hyperion"];

    nixosConfigurations.hyperion = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
      };
      modules = [self.modules.nixos.hyperion];
    };

    homeConfigurations."danieln@hyperion" = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = {
        inherit inputs;
      };
      modules = with self.modules.homeManager; [headless server];
    };

    modules.nixos.hyperion = {inputs, ...}: {
      imports =
        (with inputs.self.modules.nixos; [
          server
          cache
          caddy
          grafana
          grocy
          matrix
          miniflux
          prometheus
          jellyfin
          rqbit
          woodpecker
        ])
        ++ [./_hardware-configuration.nix];

      networking = {
        hostName = "hyperion";
        domain = "danieln.de";
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

      system.stateVersion = "22.11";
    };
  };
}
