{
  pkgs,
  flake,
  ...
}:
pkgs.writeShellScriptBin "install" ''
  set -euo pipefail

  HOST=''${1:?"Usage: install <hostname> <ip>"}
  IP=''${2:?"Usage: install <hostname> <ip>"}

  REPO=$(git -C . rev-parse --show-toplevel 2>/dev/null || pwd)
  PRIVKEY="$REPO/keys/hosts/$HOST"
  PUBKEY="$REPO/keys/hosts/$HOST.pub"
  CLEANUP_PRIVKEY=1

  if [[ ! -f "$PRIVKEY" ]]; then
    echo "Error: Pre-generated key not found: $PRIVKEY"
    echo "Generate with: ssh-keygen -t ed25519 -f $PRIVKEY -N \"\""
    exit 1
  fi

  # Prepare extra-files directory with SSH host keys
  EXTRA_DIR=$(mktemp -d)
  mkdir -p "$EXTRA_DIR/etc/ssh"
  cp "$PRIVKEY" "$EXTRA_DIR/etc/ssh/ssh_host_ed25519_key"
  cp "$PUBKEY" "$EXTRA_DIR/etc/ssh/ssh_host_ed25519_key.pub"
  chmod 600 "$EXTRA_DIR/etc/ssh/ssh_host_ed25519_key"
  chmod 644 "$EXTRA_DIR/etc/ssh/ssh_host_ed25519_key.pub"

  echo "=== Installing NixOS on $HOST via $IP ==="
  echo "Using pre-generated host key: $PUBKEY"

  ${pkgs.nixos-anywhere}/bin/nixos-anywhere \
    --flake ${flake}#$HOST \
    --target-host "root@$IP" \
    --extra-files "$EXTRA_DIR"

  # Cleanup
  rm -rf "$EXTRA_DIR"

  # Verify the deployed key matches
  DEPLOYED_KEY=$(${pkgs.openssh}/bin/ssh-keyscan -t ed25519 "$IP" 2>/dev/null | \
    ${pkgs.gawk}/bin/awk '/ssh-ed25519/ {print $2 " " $3; exit}')
  EXPECTED_KEY=$(cat "$PUBKEY" | ${pkgs.gawk}/bin/awk '{print $1 " " $2}')

  if [[ "$DEPLOYED_KEY" != "$EXPECTED_KEY" ]]; then
    echo "Warning: Deployed key does not match expected!"
    echo "Expected: $EXPECTED_KEY"
    echo "Got:      $DEPLOYED_KEY"
    exit 1
  fi

  if [[ "$CLEANUP_PRIVKEY" -eq 1 ]]; then
    rm -f "$PRIVKEY"
    echo "Deleted private key: $PRIVKEY"
  fi

  echo "=== $HOST installed with preseeded key ==="
  echo "Public key: $PUBKEY"
  echo "SSH: ssh root@$HOST"
''
