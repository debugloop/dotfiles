_: {
  flake.nixosModules.server = {top, ...}: {
    imports = with top.nixosModules; [
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
      node_exporter
      auto_upgrade
      auto_cleanup
    ];
  };

  flake.homeModules.server = {top, ...}: {
    imports = with top.homeModules; [
      ssh_agent
    ];
  };
}
