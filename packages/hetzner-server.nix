{
  pkgs,
  inputs,
  ...
}: let
  tofu = pkgs.opentofu.withPlugins (p: [p.hetznercloud_hcloud]);
in
  pkgs.writeShellScriptBin "hetzner-server" ''
    set -euo pipefail

    HOST=''${1:?"Usage: hetzner-server <hostname> [apply|destroy]"}
    shift

    CMD=''${1:-apply}
    shift || true

    ${inputs.self.lib.mkHetznerEnv "server"}

    HOST_ENABLED=$(${pkgs.nix}/bin/nix eval --json ".#nixosConfigurations.\"$HOST\".config.hetzner.enable" 2>/dev/null || echo "null")

    if [ "$HOST_ENABLED" = "null" ] || [ "$HOST_ENABLED" = "false" ]; then
      echo "Error: Host '$HOST' not found or hetzner not enabled"
      exit 1
    fi

    TFDIR=$(mktemp -d)
    trap "rm -rf $TFDIR" EXIT
    ${pkgs.nix}/bin/nix eval --json ".#nixosConfigurations.\"$HOST\".config.hetzner.terranixConfig" \
      | ${pkgs.jq}/bin/jq . > "$TFDIR/main.tf.json"

    case "$CMD" in
      destroy)
        echo "=== Destroying $HOST infrastructure on Hetzner ==="
        ${tofu}/bin/tofu -chdir="$TFDIR" init
        ${tofu}/bin/tofu -chdir="$TFDIR" destroy "$@"
        ;;
      apply)
        echo "=== Applying $HOST infrastructure to Hetzner ==="
        ${tofu}/bin/tofu -chdir="$TFDIR" init
        ${tofu}/bin/tofu -chdir="$TFDIR" apply "$@"
        IP=$(${tofu}/bin/tofu -chdir="$TFDIR" output -raw "''${HOST}_ip" 2>/dev/null || echo "")
        if [ -n "$IP" ]; then
          echo "=== Next:"
          echo "nix run .#install $HOST $IP"
        fi
        ;;
      ip)
        ${tofu}/bin/tofu -chdir="$TFDIR" init
        IP=$(${tofu}/bin/tofu -chdir="$TFDIR" output -raw "''${HOST}_ip" 2>/dev/null || echo "")
        if [ -z "$IP" ]; then
          echo "Error: IP not found for $HOST (run apply first)" >&2
          exit 1
        fi
        echo "$IP"
        ;;
      *)
        echo "Usage: hetzner-server <hostname> [apply|destroy|ip] [tofu-options...]" >&2
        exit 1
        ;;
    esac
  ''
