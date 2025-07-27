{flake, ...}: {
  imports = [
    flake.nixosModules.common
    flake.nixosModules.laptops
    ./boot.nix
  ];
}
