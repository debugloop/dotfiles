{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.simmons = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs;
    };
    modules = [self.modules.nixos.simmons];
  };

  flake.modules.nixos.simmons = {inputs, ...}: let
    storagebox = import ./_storagebox.nix;
  in {
    imports =
      (with inputs.self.modules.nixos; [client])
      ++ [./_hardware-configuration.nix];

    networking.hostName = "simmons";

    home-manager.users.danieln.home.stateVersion = "26.05";

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
