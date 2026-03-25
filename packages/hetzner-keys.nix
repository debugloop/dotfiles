{
  pkgs,
  inputs,
  ...
}: let
  inherit (pkgs) lib;

  authKeys = lib.listToAttrs (map (path: let
      name = lib.removeSuffix ".pub" (baseNameOf path);
    in {
      inherit name;
      value = builtins.readFile path;
    })
    (lib.filesystem.listFilesRecursive ../keys/auth));

  tfJson = inputs.terranix.lib.terranixConfiguration {
    system = pkgs.system;
    modules = [
      {
        terraform = {
          backend.http = {};
          required_providers.hcloud = {
            source = "hetznercloud/hcloud";
            version = "~> 1.59";
          };
        };

        variable.hcloud_token = {
          type = "string";
          sensitive = true;
        };

        provider.hcloud = {
          token = "\${var.hcloud_token}";
        };

        resource.hcloud_ssh_key =
          lib.mapAttrs (name: key: {
            inherit name;
            public_key = key;
          })
          authKeys;
      }
    ];
  };

  tofu = pkgs.opentofu.withPlugins (p: [p.hetznercloud_hcloud]);
in
  pkgs.writeShellScriptBin "hetzner-keys" ''
    set -euo pipefail

    ${inputs.self.lib.mkHetznerEnv "keys"}

    TF_DIR=$(mktemp -d)
    trap "rm -rf $TF_DIR" EXIT
    mkdir -p "$TF_DIR/.terraform"
    cp ${tfJson} "$TF_DIR/main.tf.json"

    CMD="''${1:-apply}"
    shift || true

    case "$CMD" in
      destroy)
        echo "=== Destroying Hetzner keys ==="
        ${tofu}/bin/tofu -chdir="$TF_DIR" init -plugin-dir=${tofu}/libexec/terraform-providers
        ${tofu}/bin/tofu -chdir="$TF_DIR" destroy "$@"
        ;;
      apply)
        echo "=== Applying Hetzner keys ==="
        ${tofu}/bin/tofu -chdir="$TF_DIR" init -plugin-dir=${tofu}/libexec/terraform-providers
        ${tofu}/bin/tofu -chdir="$TF_DIR" apply "$@"
        ;;
      *)
        echo "Usage: hetzner-keys [apply|destroy] [tofu-options...]" >&2
        exit 1
        ;;
    esac
  ''
