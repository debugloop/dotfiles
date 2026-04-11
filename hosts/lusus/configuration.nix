{top, inputs, ...}: {
  imports = with top.modules.nixos; [
    common_base
    common_backup_persisted
    common_hetzner
    common_impermanence
    common_nix
    common_software
    common_tailscale
    laptop_desktop
    laptop_hardware
    laptop_network
    laptop_nix
    laptop_virt
    laptop_microvm
    ./hardware-configuration.nix
  ] ++ [inputs.niri-autoselect-portal.nixosModules.default];

  system.stateVersion = "22.11";
}
