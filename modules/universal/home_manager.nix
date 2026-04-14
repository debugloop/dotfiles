{inputs, ...}: {
  imports = [inputs.home-manager.flakeModules.home-manager];

  flake.modules.nixos.home_manager = {inputs, ...}: {
    imports = [inputs.home-manager.nixosModules.home-manager];

    home-manager = {
      backupFileExtension = "bak";
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
        inherit inputs;
      };
      # users.${config.mainUser} is set by each host module
    };
  };
}
