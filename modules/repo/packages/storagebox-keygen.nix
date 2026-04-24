{inputs, ...}: let
  infraLib = import (inputs.self + "/lib/infra.nix") {
    inherit inputs;
    flake = inputs.self;
  };
in {
  perSystem = {pkgs, ...}: {
    packages.storagebox-keygen = pkgs.writeShellScriptBin "storagebox-keygen" ''
      set -euo pipefail
      echo "Decrypting access token."
      export PATH="${pkgs.age-plugin-fido2-hmac}/bin:$PATH"
      _age="${pkgs.age}/bin/age --decrypt -i ${inputs.self}/keys/physical/desk.pub"
      _secrets="$($_age ${inputs.self}/secrets/hetzner_infra.age)"
      _get() { echo "$_secrets" | grep "^$1=" | cut -d= -f2-; }
      HETZNER_TF_PASSPHRASE="$(_get tfstate_passphrase)"
      export HETZNER_TF_PASSPHRASE
      echo "Installing storage box SSH keys:"
      STORAGEBOX=$(${pkgs.opentofu}/bin/tofu -chdir=/tmp/terranix-infra output -json storagebox)
      INSTALLED=0
      FAILED=0
      ${pkgs.lib.concatMapStrings (h: ''
            PASS=$(echo "$STORAGEBOX"    | ${pkgs.jq}/bin/jq -r '.accounts.${h}.password')
            SB_HOST=$(echo "$STORAGEBOX" | ${pkgs.jq}/bin/jq -r '.accounts.${h}.host')
            SB_USER=$(echo "$STORAGEBOX" | ${pkgs.jq}/bin/jq -r '.accounts.${h}.username')
            if [[ ! -f "keys/hosts/${h}.pub" ]]; then
              echo "storagebox: missing keys/hosts/${h}.pub" >&2
              ((++FAILED))
            else
              ${pkgs.coreutils}/bin/mkdir -p "modules/universal/storagebox"
              cat > "modules/universal/storagebox/_${h}.nix" <<EOF
          {
            host = "''${SB_HOST}";
            user = "''${SB_USER}";
          }
          EOF
              if ${pkgs.sshpass}/bin/sshpass -p "$PASS" \
                   ${pkgs.openssh}/bin/ssh -p 23 \
                     -o StrictHostKeyChecking=accept-new \
                     -o UserKnownHostsFile=/dev/null \
                     -o LogLevel=ERROR \
                     "$SB_USER@$SB_HOST" install-ssh-key < "keys/hosts/${h}.pub"; then
                ((++INSTALLED))
              else
                echo "storagebox: failed to install key for ${h}" >&2
                ((++FAILED))
              fi
            fi
        '')
        infraLib.hetznerHostNames}
      [[ $FAILED -eq 0 ]] || echo "storagebox keys: $INSTALLED installed, $FAILED failed" >&2
      ${pkgs.git}/bin/git add modules/universal/storagebox/_*.nix 2>/dev/null || true
    '';
  };
}
