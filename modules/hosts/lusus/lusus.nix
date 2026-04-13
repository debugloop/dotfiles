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

  flake.modules.nixos.lusus = {inputs, ...}: {
    imports =
      (with inputs.self.modules.nixos; [client])
      ++ [./_hardware-configuration.nix];

    networking.hostName = "lusus";

    home-manager.users.danieln = {
      home.stateVersion = "22.11";
      imports = with inputs.self.modules.homeManager;
        [danieln_headless danieln_full]
        ++ [inputs.gridx.home-module];
    };

    system.stateVersion = "22.11";
  };
}
