{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.hyperion = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs;
      top = self;
    };
    modules = [self.nixosModules.hyperion];
  };

  flake.homeConfigurations."danieln@hyperion" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    extraSpecialArgs = {
      inherit inputs;
      top = self;
    };
    modules = with self.homeModules; [danieln ssh_agent];
  };

  flake.nixosModules.hyperion = {
    top,
    pkgs,
    config,
    ...
  }: {
    imports =
      (with top.nixosModules; [
        common_home_manager
        common_network
        common_openssh
        common_locale
        common_users
        common_vm
        common_backup_persisted
        common_hetzner
        common_impermanence
        common_nix
        common_software
        common_tailscale
        node_exporter
        auto_upgrade
        auto_cleanup
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
      ])
      ++ [./_hardware-configuration.nix];

    networking.hostName = "hyperion";
    networking.nameservers = [
      "9.9.9.9"
      "149.112.112.112"
      "2620:fe::fe"
      "2620:fe::9"
    ];
    networking.useDHCP = false;
    networking.interfaces.ens3 = {
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
    networking.defaultGateway = {
      address = "37.120.188.1";
      interface = "ens3";
    };
    networking.defaultGateway6 = {
      address = "fe80::1";
      interface = "ens3";
    };

    home-manager.users.danieln = {
      home.stateVersion = "22.11";
      imports = with top.homeModules; [danieln ssh_agent];
    };

    system.stateVersion = "22.11";

    users.users.root.openssh.authorizedKeys.keys =
      map
      (name: builtins.readFile (../../../keys/auth + "/${name}.pub"))
      config.hetzner.sshKeyNames;
  };
}
