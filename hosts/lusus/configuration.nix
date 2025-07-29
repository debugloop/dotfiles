{flake, ...}: {
  imports = [
    ./hardware-configuration.nix
    flake.nixosModules.common
    flake.nixosModules.class-laptop
  ];
}
