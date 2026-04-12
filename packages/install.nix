{
  pkgs,
  inputs,
  ...
}: let
  inherit (inputs.self.packages.${pkgs.system}) infra;
in
  pkgs.writeShellScriptBin "install" ''
    set -euo pipefail

    HOST=''${1:?"Usage: install <hostname> [ip]"}
    IP=''${2:-$(${infra}/bin/infra output -json addresses | ${pkgs.jq}/bin/jq -r --arg h "$HOST" '.[$h].v4')}

    REPO=$(git -C . rev-parse --show-toplevel 2>/dev/null || pwd)
    PRIVKEY="$REPO/keys/hosts/$HOST"
    PUBKEY="$REPO/keys/hosts/$HOST.pub"
    INSTALL_OK=0

    if [[ ! -f "$PRIVKEY" ]]; then
      echo "Error: Pre-generated key not found: $PRIVKEY"
      echo "Generate with: host-keygen $HOST"
      echo "Reminder: run 'nix run .#infra -- apply' before install."
      exit 1
    fi

    # Prepare extra-files directory with SSH host keys
    EXTRA_DIR=$(mktemp -d)
    trap 'rm -rf "$EXTRA_DIR"; if [[ "$INSTALL_OK" -eq 1 ]]; then rm -f "$PRIVKEY"; echo "Deleted private key: $PRIVKEY"; echo "Reminder: run sudo agenix -r to reencrypt with the new host key."; fi' EXIT
    mkdir -p "$EXTRA_DIR/nix/persist/etc/ssh"
    cp "$PRIVKEY" "$EXTRA_DIR/nix/persist/etc/ssh/ssh_host_ed25519_key"
    cp "$PUBKEY" "$EXTRA_DIR/nix/persist/etc/ssh/ssh_host_ed25519_key.pub"
    chmod 600 "$EXTRA_DIR/nix/persist/etc/ssh/ssh_host_ed25519_key"
    chmod 644 "$EXTRA_DIR/nix/persist/etc/ssh/ssh_host_ed25519_key.pub"

    echo "=== Installing NixOS on $HOST via $IP ==="
    echo "Using pre-generated host key: $PUBKEY"

    ${pkgs.nixos-anywhere}/bin/nixos-anywhere \
      --flake ${inputs.self}#$HOST \
      --target-host "root@$IP" \
      --extra-files "$EXTRA_DIR"

    INSTALL_OK=1

    echo "=== $HOST installed with preseeded key ==="
    echo "Public key: $PUBKEY"
    echo "SSH: ssh root@$HOST"
  ''
