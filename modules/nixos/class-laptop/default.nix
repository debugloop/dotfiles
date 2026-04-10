{inputs, ...}: {
  imports = [
    ./desktop.nix
    ./hardware.nix
    ./network.nix
    ./nix.nix
    ./virt.nix
    ./microvm.nix
    inputs.niri-autoselect-portal.nixosModules.default
  ];
}
