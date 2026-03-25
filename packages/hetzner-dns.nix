{
  pkgs,
  inputs,
  ...
}: let
  inherit (pkgs) lib;

  zones = [
    "danieln.de"
    "bugpara.de"
  ];

  isWildcard = host: lib.hasPrefix "*." host;
  hasPort = host: lib.hasInfix ":" host;
  isFqdn = host: lib.hasInfix "." host;
  zoneForHost = host: lib.findFirst (z: lib.hasSuffix ".${z}" host) null zones;

  warnIfOutside = host:
    if isFqdn host && zoneForHost host == null && !hasPort host && !isWildcard host then
      builtins.trace "Warning: Caddy vhost ${host} is not in dns.zones; skipping DNS record"
        host
    else
      host;

  hostEntries =
    lib.mapAttrsToList (host: cfg: {
      hostName = cfg.config.networking.hostName;
      hetznerEnabled = cfg.config.hetzner.enable or false;
      dnsZone = cfg.config.hetzner.dnsZone or null;
      vhosts = builtins.attrNames (cfg.config.services.caddy.virtualHosts or {});
    })
    inputs.self.nixosConfigurations;

  cnameRecords =
    lib.concatMap
    (h:
      if !h.hetznerEnabled then
        []
      else
        let
          vhosts = map warnIfOutside h.vhosts;
          valid = lib.filter (vh:
            let z = zoneForHost vh;
            in z != null && vh != z && !hasPort vh && !isWildcard vh
          ) vhosts;
        in
          map (vh: let
            z = zoneForHost vh;
            name = lib.removeSuffix ".${z}" vh;
          in {
            fqdn = vh;
            zone = z;
            inherit name;
            target = "${h.hostName}.${z}";
          }) valid
    )
    hostEntries;

  cnameAttrs = lib.listToAttrs (map (r: {
      name = lib.replaceStrings ["."] ["-"] r.fqdn;
      value = {
        zone = r.zone;
        name = r.name;
        type = "CNAME";
        value = r.target;
      };
    })
    cnameRecords);

  recordAttrs = cnameAttrs;

  zoneAttrs = lib.listToAttrs (map (z: {
      name = lib.replaceStrings ["."] ["-"] z;
      value = {
        name = z;
        mode = "primary";
      };
    })
    zones);

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

        resource.hcloud_zone = zoneAttrs;
        resource.hcloud_zone_record = recordAttrs;
      }
    ];
  };

  tofu = pkgs.opentofu.withPlugins (p: [p.hetznercloud_hcloud]);
in
  pkgs.writeShellScriptBin "hetzner-dns" ''
    set -euo pipefail

    ${inputs.self.lib.mkHetznerEnv "dns"}

    TF_DIR=$(mktemp -d)
    trap "rm -rf $TF_DIR" EXIT
    mkdir -p "$TF_DIR/.terraform"
    cp ${tfJson} "$TF_DIR/main.tf.json"

    CMD="''${1:-apply}"
    shift || true

    case "$CMD" in
      apply)
        echo "=== Applying Hetzner DNS (zones + CNAMEs) ==="
        ${tofu}/bin/tofu -chdir="$TF_DIR" init -plugin-dir=${tofu}/libexec/terraform-providers
        ${tofu}/bin/tofu -chdir="$TF_DIR" apply "$@"
        ;;
      *)
        echo "Usage: hetzner-dns [apply] [tofu-options...]" >&2
        exit 1
        ;;
    esac
  ''
