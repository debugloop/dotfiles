_: {
  flake.nixosModules.server = {top, ...}: {
    imports = with top.nixosModules; [
      home_manager
      network
      openssh
      locale
      users
      vm
      backup_persisted
      hetzner
      impermanence
      nix
      software
      tailscale
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
