_: {
  flake.modules.nixos.host = {inputs, ...}: {
    imports = with inputs.self.modules.nixos; [
      home_manager
      agenix
      nix

      nixpkgs
      network
      openssh
      locale
      users
      vm
      backup_persisted
      hetzner
      impermanence
      software
      tailscale
      fish
      nvim
    ];
  };
}
