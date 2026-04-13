_: {
  flake.nixosModules.host = {top, ...}: {
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
    ];
  };
}
