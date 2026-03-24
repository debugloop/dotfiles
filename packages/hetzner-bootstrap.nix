{
  pkgs,
  ...
}:
  pkgs.writeShellScriptBin "hetzner-bootstrap" ''
    set -euo pipefail

    HOST=''${1:?"Usage: hetzner-bootstrap <hostname>"}

    prompt() {
      echo
      read -r -p "==> $1 [y/N]: " ans
      case "$ans" in
        y|Y|yes|YES) return 0 ;;
        *) echo "Aborted."; exit 1 ;;
      esac
    }

    echo "=== Hetzner bootstrap for $HOST ==="
    echo "This script orchestrates the following steps:"
    echo "  1) Ensure host SSH key exists (host-keygen)"
    echo "  2) Provision shared Hetzner env + Storage Box subaccounts (hetzner-env)"
    echo "  3) Provision the host server (hetzner-server)"
    echo "  4) Install NixOS via nixos-anywhere (install)"
    echo
    echo "Each step is interactive and can be re-run independently via the corresponding package."
    echo
    echo "Delete/recreate workflow (manual reference):"
    echo "  - Destroy host infra:   nix run .#hetzner-server -- $HOST destroy"
    echo "  - Recreate host infra:  nix run .#hetzner-server -- $HOST apply"
    echo "  - Reinstall NixOS:      nix run .#install -- $HOST <IP>"
    echo "  - (Optional) reset env: nix run .#hetzner-env -- apply"

    # Step 1: Host SSH key (used for Storage Box SSH key install + host key seeding)
    if [[ -f "./keys/hosts/$HOST" && -f "./keys/hosts/$HOST.pub" ]]; then
      echo "Host key exists: ./keys/hosts/$HOST(.pub)"
    else
      prompt "Generate host SSH key for $HOST?"
      ${pkgs.nix}/bin/nix run .#host-keygen -- "$HOST"
      echo "Staging ./keys/hosts/$HOST.pub so Nix can see it..."
      ${pkgs.git}/bin/git add "./keys/hosts/$HOST.pub"
      echo "Note: the private key is NOT staged."
    fi

    # Step 2: Hetzner environment + Storage Box subaccounts (and SSH key install)
    prompt "Apply Hetzner env (shared infra + Storage Box subaccounts)?"
    ${pkgs.nix}/bin/nix run .#hetzner-env -- apply
    if [[ -f "hosts/$HOST/storagebox.nix" ]]; then
      echo "Staging hosts/$HOST/storagebox.nix so Nix can see it..."
      ${pkgs.git}/bin/git add "hosts/$HOST/storagebox.nix"
    fi

    # Step 3: Provision the host server on Hetzner
    prompt "Apply Hetzner server for $HOST?"
    ${pkgs.nix}/bin/nix run .#hetzner-server -- "$HOST" apply
    IP=$(${pkgs.nix}/bin/nix run .#hetzner-server -- "$HOST" ip 2>/dev/null || true)
    IP=$(echo "$IP" | ${pkgs.gnugrep}/bin/grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n1 || true)

    # Step 4: Install NixOS on the server
    echo
    if [[ -z "$IP" ]]; then
      echo
      echo "Could not fetch IP from hetzner-server."
      read -r -p "Enter IP for $HOST (from hetzner-server output): " IP
    else
      echo
      echo "Parsed IP from hetzner-server output: $IP"
    fi
    prompt "Run nixos-anywhere install for $HOST at $IP?"
    ${pkgs.nix}/bin/nix run .#install -- "$HOST" "$IP"

    echo
    echo "=== Manual tasks left ==="
    echo "1) Review generated files (e.g., hosts/$HOST/storagebox.nix)."
    echo "2) git add + commit those changes so the new host can pull them later."
    echo "3) (Optional) trigger a self-build on the host when convenient."
    echo
    echo "Bootstrap finished for $HOST."
  ''
