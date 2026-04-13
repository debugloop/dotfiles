{inputs, ...}: let
  infraLib = import (inputs.self + "/lib/infra.nix") {
    inherit inputs;
    flake = inputs.self;
  };
in {
  imports = [inputs.terranix.flakeModule inputs.git-hooks-nix.flakeModule];

  perSystem = {
    pkgs,
    config,
    ...
  }: let
    passphraseScript = pkgs.writeShellScript "infra-passphrase" ''
      set -euo pipefail
      printf '{"magic":"OpenTofu-External-Key-Provider","version":1}\n'
      IFS= read -r _ || :
      _b64="$(printf '%s' "$HETZNER_TF_PASSPHRASE" | ${pkgs.coreutils}/bin/base64 -w0)"
      printf '{"keys":{"encryption_key":"%s","decryption_key":"%s"}}\n' "$_b64" "$_b64"
    '';
  in {
    pre-commit.settings.hooks.storagebox-key-reminder = {
      enable = true;
      name = "storagebox key reminder";
      entry = toString (pkgs.writeShellScript "storagebox-key-reminder" ''
        echo ""
        echo "Host key changed — remember to reinstall storage box SSH keys:"
        echo "  nix run .#storagebox-keygen"
        echo ""
      '');
      files = "^keys/hosts/.*\\.pub$";
      pass_filenames = false;
    };

    terranix.terranixConfigurations.infra = {
      workdir = "/tmp/terranix-infra";
      terraformWrapper = {
        package = pkgs.opentofu.withPlugins (p: [p.hetznercloud_hcloud p.hashicorp_random]);
        prefixText = ''
          REPO_DIR="$PWD"
          export PATH="${pkgs.age-plugin-fido2-hmac}/bin:$PATH"
          _age="${pkgs.age}/bin/age --decrypt -i ${inputs.self}/keys/physical/desk.pub"
          _secrets="$($_age ${inputs.self}/secrets/hetzner_infra.age)"
          _get() { echo "$_secrets" | grep "^$1=" | cut -d= -f2-; }
          TF_VAR_hcloud_token="$(_get hcloud_token)"
          TF_VAR_storage_box_id="$(_get storage_box_id)"
          HETZNER_TF_PASSPHRASE="$(_get tfstate_passphrase)"
          export TF_VAR_hcloud_token TF_VAR_storage_box_id HETZNER_TF_PASSPHRASE REPO_DIR
        '';
        suffixText = ''
          if [[ "$1" == "apply" ]]; then
            ${config.packages.storagebox-keygen}/bin/storagebox-keygen
          fi
        '';
      };
      modules =
        infraLib.hetznerModules
        ++ [
          {
            terraform.encryption = {
              key_provider.external.passphrase.command = ["${passphraseScript}"];
              key_provider.pbkdf2.main.chain = "\${key_provider.external.passphrase}";
              method.aes_gcm.default.keys = "\${key_provider.pbkdf2.main}";
              state.method = "method.aes_gcm.default";
              state.enforced = true;
            };
          }
        ];
    };
  };
}
