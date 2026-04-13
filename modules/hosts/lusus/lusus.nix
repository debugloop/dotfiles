{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.lusus = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs;
      top = self;
    };
    modules = [self.nixosModules.lusus];
  };

  flake.nixosModules.lusus = {
    top,
    inputs,
    ...
  }: {
    imports =
      (with top.nixosModules; [client])
      ++ [./_hardware-configuration.nix];

    networking.hostName = "lusus";

    home-manager.users.danieln = {
      home.stateVersion = "22.11";
      imports = with top.homeModules;
        [danieln_headless danieln_full]
        ++ [inputs.gridx.home-module];
    };

    system.stateVersion = "22.11";
  };
}
