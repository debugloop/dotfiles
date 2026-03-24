{
  pkgs,
  ...
}:
  pkgs.writeShellScriptBin "host-keygen" ''
    set -euo pipefail

    HOST=''${1:?-"Usage: host-keygen <hostname> [--force]"}
    FORCE=''${2:-}

    KEYDIR="./keys/hosts"
    PRIVKEY="$KEYDIR/$HOST"
    PUBKEY="$KEYDIR/$HOST.pub"

    mkdir -p "$KEYDIR"

    if [[ -f "$PRIVKEY" && "$FORCE" != "--force" ]]; then
      echo "Error: $PRIVKEY already exists. Use --force to overwrite." >&2
      exit 1
    fi

    if [[ -f "$PRIVKEY" && "$FORCE" == "--force" ]]; then
      rm -f "$PRIVKEY" "$PUBKEY"
    fi

    ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f "$PRIVKEY" -N "" -C "$HOST"

    chmod 600 "$PRIVKEY"
    chmod 644 "$PUBKEY"

    echo "Created host key pair:"
    echo "  $PRIVKEY"
    echo "  $PUBKEY"
  ''
