_: {
  flake.modules.nixos.profile_base = {inputs, ...}: {
    imports = with inputs.self.modules.nixos; [
      home_manager
      agenix
      coretools
      fish
      nix
      nvim

      network
      ssh
      locale
      account
      vm
      backup_persisted
      impermanence
      tailscale
    ];
  };
}
