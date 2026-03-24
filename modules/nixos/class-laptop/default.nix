{inputs, ...}: {
  imports = [
    ./desktop.nix
    ./hardware.nix
    ./network.nix
    ./nix.nix
    ./secrets.nix
    ./virt.nix
    inputs.niri-autoselect-portal.nixosModules.default
  ];
}
