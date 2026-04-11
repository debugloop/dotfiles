{ ... }: {
  flake.modules.nixos.common_home_manager = {
    inputs,
    top,
    hostName,
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
      users.danieln = import ../../hosts/${hostName}/home.nix;
    };
  };
}
