{top, inputs, ...}: {
  imports = with top.modules.nixos; [
    common_home_manager
    common_network
    common_openssh
    common_locale
    common_users
    common_vm
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
  # environment.systemPackages = with pkgs; [
  #   factorio
  # ];
}
