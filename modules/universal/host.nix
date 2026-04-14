_: {
  flake.modules.nixos.host = {inputs, ...}: {
    imports = with inputs.self.modules.nixos; [
      main_user
      home_manager
      agenix
      ai
      development
      extra
      fish
      nix
      nvim
      online

      nixpkgs
      network
      openssh
      locale
      users
      vm
      backup_persisted
      storagebox
      hetzner
      impermanence
      software
      tailscale
    ];
  };
}
