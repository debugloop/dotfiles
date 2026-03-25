{
  pkgs,
  inputs,
  ...
}: let
  inherit (pkgs) lib;

  hostKeyFiles = lib.filter (lib.hasSuffix ".pub") (lib.filesystem.listFilesRecursive ../keys/hosts);
  hostNames = map (f: lib.removeSuffix ".pub" (baseNameOf f)) hostKeyFiles;

  tfJson = inputs.terranix.lib.terranixConfiguration {
    system = pkgs.system;
    modules = [
      {
        terraform = {
          backend.http = {};
          required_providers = {
            hcloud = {
              source = "hetznercloud/hcloud";
              version = "~> 1.45";
            };
            random = {
              source = "hashicorp/random";
              version = "~> 3.0";
            };
          };
        };
        variable.hcloud_token = {
          type = "string";
          sensitive = true;
        };
        variable.storage_box_id = {
          type = "number";
          description = "Parent storage box numeric ID";
        };

        provider.hcloud = {
          token = "\${var.hcloud_token}";
        };

        resource.random_password = lib.listToAttrs (map (hostName: {
            name = hostName;
            value = {
              length = 64;
              # Hetzner storage box password charset restrictions
              special = true;
              override_special = "^!$%/()=?+#-.,;:~*@{}_&";
              min_upper = 1;
              min_lower = 1;
              min_numeric = 1;
              min_special = 1;
            };
          })
          hostNames);

        resource.hcloud_storage_box_subaccount = lib.listToAttrs (map (hostName: {
            name = hostName;
            value = {
              storage_box_id = "\${var.storage_box_id}";
              name = hostName;
              home_directory = hostName;
              password = "\${random_password.${hostName}.result}";
              access_settings = {
                ssh_enabled = true;
                reachable_externally = true;
                samba_enabled = false;
                webdav_enabled = false;
                readonly = false;
              };
            };
          })
          hostNames);

        data.hcloud_storage_box.parent = {
          id = "\${var.storage_box_id}";
        };

        output.subaccounts = {
          value = lib.listToAttrs (map (hostName: {
              name = hostName;
              value = {
                host = "\${hcloud_storage_box_subaccount.${hostName}.server}";
                username = "\${hcloud_storage_box_subaccount.${hostName}.username}";
                password = "\${random_password.${hostName}.result}";
              };
            })
            hostNames);
          sensitive = true;
        };
      }
    ];
  };

  tofu = pkgs.opentofu.withPlugins (p: [p.hetznercloud_hcloud p.random]);
  sshpass = pkgs.sshpass;
in
  pkgs.writeShellScriptBin "hetzner-storagebox" ''
    set -euo pipefail

    ${inputs.self.lib.mkHetznerEnv "storagebox"}

    TF_DIR=$(mktemp -d)
    trap "rm -rf $TF_DIR" EXIT
    mkdir -p "$TF_DIR/.terraform"
    cp ${tfJson} "$TF_DIR/main.tf.json"

    CMD="''${1:-apply}"
    shift || true

    case "$CMD" in
      destroy)
        echo "=== Destroying Hetzner storage box subaccounts ==="
        ${tofu}/bin/tofu -chdir="$TF_DIR" init -plugin-dir=${tofu}/libexec/terraform-providers
        ${tofu}/bin/tofu -chdir=$TF_DIR destroy "$@"
        ;;
      apply)
        echo "=== Applying Hetzner storage box subaccounts ==="
        ${tofu}/bin/tofu -chdir="$TF_DIR" init -plugin-dir=${tofu}/libexec/terraform-providers
        ${tofu}/bin/tofu -chdir=$TF_DIR apply "$@"

        echo "=== Installing storage box SSH keys ==="

        PASSWORDS=$(${tofu}/bin/tofu -chdir=$TF_DIR output -json subaccounts)

        INSTALLED=0
        FAILED=0
        MAPPED=0

        ${lib.concatMapStrings (hostName: ''
        echo "  Installing key for ${hostName}..."
        PASS=$(echo "$PASSWORDS" | ${pkgs.jq}/bin/jq -r '.${hostName}.password')
        SB_HOST=$(echo "$PASSWORDS" | ${pkgs.jq}/bin/jq -r '.${hostName}.host')
        SB_USER=$(echo "$PASSWORDS" | ${pkgs.jq}/bin/jq -r '.${hostName}.username')
        PUBKEY_PATH="keys/hosts/${hostName}.pub"
        MAP_PATH="hosts/${hostName}/storagebox.nix"

        if [[ ! -f "$PUBKEY_PATH" ]]; then
          echo "  Error: missing host public key $PUBKEY_PATH" >&2
          ((++FAILED))
        else
          ${pkgs.coreutils}/bin/mkdir -p "hosts/${hostName}"
          cat > "$MAP_PATH" <<EOF
          {
            host = "''${SB_HOST}";
            user = "''${SB_USER}";
          }
EOF
          ((++MAPPED))
          ${sshpass}/bin/sshpass -p "$PASS" \
            ${pkgs.openssh}/bin/ssh -p 23 \
              -o StrictHostKeyChecking=accept-new \
              -o UserKnownHostsFile=/dev/null \
              "$SB_USER@$SB_HOST" install-ssh-key < "$PUBKEY_PATH" && ((++INSTALLED)) || ((++FAILED))
        fi
      '')
      hostNames}

        echo "=== Done: $INSTALLED installed, $FAILED failed, $MAPPED mapped ==="
        ;;
      *)
        echo "Usage: hetzner-storagebox [apply|destroy] [tofu-options...]" >&2
        exit 1
        ;;
    esac
  ''
