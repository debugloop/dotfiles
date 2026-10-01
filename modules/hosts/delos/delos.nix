{
  self,
  inputs,
  ...
}: {
  flake = {
    diskoConfigurations.delos = import ./_disko.nix {
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    };

    nixosConfigurations.delos = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
      };
      modules = [self.modules.nixos.delos];
    };

    modules.nixos.delos = {
      config,
      inputs,
      ...
    }: {
      imports =
        (with inputs.self.modules.nixos; [
          profile_base
          profile_client
          profile_development
          hister_work
          nvidia
        ])
        ++ [
          ./_hardware-configuration.nix
          inputs.disko.nixosModules.disko
        ];

      networking.hostName = "delos";

      disko.devices = inputs.self.diskoConfigurations.delos.disko.devices;
      boot.initrd.systemd.fido2.enable = true;

      # TODO: Assign a dedicated StorageBox account before enabling backups.
      backup.enable = false;

      home-manager.users.${config.mainUser}.home.stateVersion = "26.11";

      # The swap file stays inside LUKS. Hibernation is not configured.
      swapDevices = [
        {
          device = "/nix/swapfile";
          size = 16 * 1024;
        }
      ];

      system.stateVersion = "26.11";
    };
  };
}
