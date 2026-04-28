{
  inputs,
  lib,
  ...
}: let
  # Get all nixosConfigurations that have both cache and tailscale enabled
  # Tailscale is required for magic DNS to resolve hostnames
  cacheHosts =
    lib.filterAttrs (
      _: cfg: (cfg.config.nix.sshServe.enable or false) && (cfg.config.services.tailscale.enable or false)
    )
    inputs.self.nixosConfigurations;

  # Read a host's SSH public key and encode it as base64 (URL-safe)
  readHostKey = name: let
    keyFile = inputs.self + "/keys/hosts/${name}.pub";
    keyContent = builtins.readFile keyFile;
    # Extract just the key part (not the comment)
    keyParts = lib.splitString " " keyContent;
    keyB64 = lib.elemAt keyParts 1;
  in
    keyB64;

  # Generate a substituter entry for a cache host
  mkSubstituter = name: _: let
    keyB64 = readHostKey name;
  in "ssh://nix-ssh@${name}?trusted=true&ssh-key=/etc/ssh/ssh_host_ed25519_key&priority=100&base64-ssh-public-host-key=${keyB64}&compress=true";
in {
  flake.modules.nixos.substituters = _: {
    nix.settings.extra-substituters = lib.mapAttrsToList mkSubstituter cacheHosts;
  };
}
