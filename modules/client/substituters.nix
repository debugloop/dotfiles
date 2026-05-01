{
  inputs,
  lib,
  ...
}: let
  cacheHosts =
    lib.filterAttrs (
      _: cfg: (cfg.config.nix.sshServe.enable or false) && (cfg.config.services.tailscale.enable or false)
    )
    inputs.self.nixosConfigurations;

  mkSubstituter = pkgs: name: _: let
    keyFile = inputs.self + "/keys/hosts/${name}.pub";
    b64HostKey = builtins.readFile (pkgs.runCommandLocal "b64key-${name}" {} ''
      ${pkgs.coreutils}/bin/head -1 ${keyFile} \
        | ${pkgs.coreutils}/bin/cut -d' ' -f1,2 \
        | ${pkgs.coreutils}/bin/base64 -w0 \
        > $out
    '');
  in "ssh://nix-ssh@${name}?trusted=true&ssh-key=/etc/ssh/ssh_host_ed25519_key&priority=100&base64-ssh-public-host-key=${b64HostKey}&compress=true";
in {
  flake.modules.nixos.substituters = {pkgs, ...}: {
    nix.settings.extra-substituters = lib.mapAttrsToList (mkSubstituter pkgs) cacheHosts;
  };
}
