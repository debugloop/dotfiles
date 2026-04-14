{inputs, ...}: {
  imports = [inputs.home-manager.flakeModules.home-manager];

  flake.modules.nixos.home_manager = {
    config,
    inputs,
    lib,
    ...
  }: {
    imports = [inputs.home-manager.nixosModules.home-manager];

    home-manager = {
      backupFileExtension = "bak";
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
        inherit inputs;
        inherit (config) mainUser;
      };
      users.${config.mainUser}.home.stateVersion = lib.mkDefault "22.11";
    };
  };
}
