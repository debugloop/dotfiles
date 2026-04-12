{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.simmons = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs;
      top = self;
    };
    modules = [self.nixosModules.simmons];
  };

  flake.nixosModules.simmons = {top, ...}: {
    imports =
      (with top.nixosModules; [laptop])
      ++ [./_hardware-configuration.nix];

    networking.hostName = "simmons";

    home-manager.users.danieln = {
      home.stateVersion = "26.05";
      imports = with top.homeModules; [danieln laptop];
    };

    backup.enable = true;
    system.stateVersion = "26.05";

    codingVmsExternalInterface = "wlp2s0";

    codingVms = [
      {
        name = "codingvm";
        workspace = "/home/danieln/microvm/coding";
      }
    ];

    programs = {
      gamemode.enable = true;
      steam.enable = true;
    };
  };
}
