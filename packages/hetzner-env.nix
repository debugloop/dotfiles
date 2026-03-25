{
  pkgs,
  ...
}:
  pkgs.writeShellScriptBin "hetzner-env" ''
    set -euo pipefail

    CMD="''${1:-apply}"
    shift || true

    case "$CMD" in
      destroy)
        echo "Error: destroy is not supported. Use the specific scripts." >&2
        exit 1
        ;;
      apply)
        echo "=== Applying Hetzner env (keys + dns + storage box) ==="
        ${pkgs.nix}/bin/nix run .#hetzner-keys -- apply "$@"
        ${pkgs.nix}/bin/nix run .#hetzner-dns -- apply "$@"
        ${pkgs.nix}/bin/nix run .#hetzner-storagebox -- apply "$@"
        ;;
      *)
        echo "Usage: hetzner-env [apply] [tofu-options...]" >&2
        exit 1
        ;;
    esac
  ''
