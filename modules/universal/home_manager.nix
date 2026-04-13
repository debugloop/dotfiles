{inputs, ...}: {
  imports = [inputs.home-manager.flakeModules.home-manager];

  flake.nixosModules.home_manager = {
    inputs,
    top,
    ...
  }: {
    imports = [inputs.home-manager.nixosModules.home-manager];

    home-manager = {
      backupFileExtension = "bak";
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
        inherit inputs top;
      };
      # users.danieln is set by each host module
    };
  };
}
