{
  pkgs,
  inputs,
  ...
}: let
  inherit (pkgs) lib;
  infra = import ../lib/infra.nix {
    inherit inputs;
    flake = inputs.self;
  };
  terranix = infra.hetznerTerranix pkgs;
  hostNames = infra.hetznerHostNames;
  tofu = pkgs.opentofu.withPlugins (p: [p.hetznercloud_hcloud p.hashicorp_random]);
in
  pkgs.writeShellScriptBin "infra" ''
    set -euo pipefail

    export PATH="${pkgs.age-plugin-fido2-hmac}/bin:$PATH"
    _age="${pkgs.age}/bin/age --decrypt -i ${inputs.self}/keys/physical/desk.pub"

    _secrets="$($_age ${inputs.self}/secrets/hetzner_infra.age)"
    _get() { echo "$_secrets" | grep "^$1=" | cut -d= -f2-; }

    export TF_VAR_hcloud_token="$(_get hcloud_token)"
    export TF_VAR_storage_box_id="$(_get storage_box_id)"

    export TF_ENCRYPTION=$(cat <<TFENC
    key_provider "pbkdf2" "key" {
      passphrase = "$(_get tfstate_passphrase)"
    }
    method "aes_gcm" "default" {
      keys = key_provider.pbkdf2.key
    }
    state {
      method   = method.aes_gcm.default
      enforced = true
    }
    TFENC
    )

    TOFU="${tofu}/bin/tofu"
    PLUGIN_DIR="${tofu}/libexec/terraform-providers"

    TF_DIR=$(mktemp -d)
    trap "rm -rf $TF_DIR" EXIT
    install -m644 "${terranix}" "$TF_DIR/main.tf.json"

    _init() { "$TOFU" -chdir="$TF_DIR" init -plugin-dir="$PLUGIN_DIR" > /dev/null; }

    _install_storagebox_keys() {
      echo ""
      echo "Installing storage box SSH keys:"
      local STORAGEBOX INSTALLED=0 FAILED=0
      STORAGEBOX=$("$TOFU" -chdir="$TF_DIR" output -json storagebox)

    ${lib.concatMapStrings (h: ''
        PASS=$(echo "$STORAGEBOX"    | ${pkgs.jq}/bin/jq -r '.accounts.${h}.password')
        SB_HOST=$(echo "$STORAGEBOX" | ${pkgs.jq}/bin/jq -r '.accounts.${h}.host')
        SB_USER=$(echo "$STORAGEBOX" | ${pkgs.jq}/bin/jq -r '.accounts.${h}.username')
        if [[ ! -f "keys/hosts/${h}.pub" ]]; then
          echo "storagebox: missing keys/hosts/${h}.pub" >&2
          ((++FAILED))
        else
          ${pkgs.coreutils}/bin/mkdir -p "modules/hosts/${h}"
          cat > "modules/hosts/${h}/_storagebox.nix" <<EOF
        {
          host = "''${SB_HOST}";
          user = "''${SB_USER}";
        }
        EOF
          ${pkgs.sshpass}/bin/sshpass -p "$PASS" \
            ${pkgs.openssh}/bin/ssh -p 23 \
              -o StrictHostKeyChecking=accept-new \
              -o UserKnownHostsFile=/dev/null \
              -o LogLevel=ERROR \
              "$SB_USER@$SB_HOST" install-ssh-key < "keys/hosts/${h}.pub" \
            && ((++INSTALLED)) \
            || { echo "storagebox: failed to install key for ${h}" >&2; ((++FAILED)); }
        fi
      '')
      hostNames}

      [[ $FAILED -eq 0 ]] || echo "storagebox keys: $INSTALLED installed, $FAILED failed" >&2
      ${pkgs.git}/bin/git add modules/hosts/*/_storagebox.nix 2>/dev/null || true
    }

    CMD=''${1:-apply}
    shift || true

    case "$CMD" in
      apply)
        _init
        "$TOFU" -chdir="$TF_DIR" apply "$@"
        _install_storagebox_keys
        ;;
      *)
        _init
        "$TOFU" -chdir="$TF_DIR" "$CMD" "$@"
        ;;
    esac
  ''
