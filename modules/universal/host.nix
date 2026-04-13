_: {
  flake.modules.nixos.host = {inputs, ...}: {
    imports = with inputs.self.modules.nixos; [
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
