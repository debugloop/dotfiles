{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.lusus = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs;
    };
    modules = [self.modules.nixos.lusus];
  };

  flake.modules.nixos.lusus = {
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
      ])
      ++ [./_hardware-configuration.nix];

    networking.hostName = "lusus";

    backup.storagebox = import ../../features/storage/storagebox/_lusus.nix;

    home-manager.users.${config.mainUser} = {
      imports = with inputs.gridx.modules.homeManager; [
        gridx
        gridx_pi_gateway
      ];
      programs.firefox.configPath = ".mozilla/firefox";
    };

    system.stateVersion = "22.11";
  };
}
