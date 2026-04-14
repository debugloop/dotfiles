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
      (with inputs.self.modules.nixos; [client])
      ++ [./_hardware-configuration.nix];

    networking.hostName = "lusus";

    home-manager.users.${config.mainUser} = {
      imports = [inputs.gridx.home-module];
    };

    system.stateVersion = "22.11";
  };
}
