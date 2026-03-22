{
  pkgs,
  perSystem,
  ...
}: let
  allKeys =
    map pkgs.lib.fileContents
    (pkgs.lib.filesystem.listFilesRecursive ./keys);

  secretsNix = pkgs.writeText "secrets.nix" ''
    let
      all = [
        ${pkgs.lib.concatMapStringsSep "\n  " (k: ''"${pkgs.lib.trim k}"'') allKeys}
      ];
    in
    {
      "secrets/password.age".publicKeys = all;
      "secrets/restic_password.age".publicKeys = all;
      "secrets/tailscale.age".publicKeys = all;
      "secrets/grafana.age".publicKeys = all;
      "secrets/gh-token.age".publicKeys = all;
      "secrets/miniflux.age".publicKeys = all;
      "secrets/factorio.age".publicKeys = all;
      "secrets/mullvad.conf.age".publicKeys = all;
      "secrets/woodpecker.age".publicKeys = all;
      "secrets/hetzner_token.age".publicKeys = all;
      "secrets/hetzner_storagebox_tfstate_user.age".publicKeys = all;
      "secrets/hetzner_storagebox_tfstate_password.age".publicKeys = all;
    }
  '';

  agenixWrapped = pkgs.writeShellScriptBin "agenix" ''
    export RULES="${secretsNix}"

    if [ "$USER" = "root" ]; then
      identity_file="/etc/ssh/ssh_host_ed25519_key"
    else
      identity_file="''${HOME}/.ssh/id_ed25519"
    fi

    ${perSystem.agenix.default}/bin/agenix -i "$identity_file" "$@"

    if [ -n "$SUDO_USER" ]; then
      chown -R "$SUDO_USER:" secrets/ 2>/dev/null || true
    fi
  '';
in
  pkgs.mkShell {
    packages = [
      agenixWrapped
    ];
  }
