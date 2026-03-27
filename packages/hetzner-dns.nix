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
    lib.mapAttrsToList (_: cfg: {
      hostName = cfg.config.networking.hostName;
      hetznerEnabled = cfg.config.hetzner.enable or false;
      vhosts = builtins.attrNames (cfg.config.services.caddy.virtualHosts or {});
    })
    inputs.self.nixosConfigurations;

  mkIpRef = hostName: attr: "\${data.hcloud_server.${hostName}.${attr}}";

  recordList = lib.concatMap (h:
    if !h.hetznerEnabled then []
    else
      let
        vhosts = map warnIfOutside h.vhosts;
      in
        # hostname.zone A/AAAA in all zones
        lib.concatMap (z: [
          {zone = z; name = h.hostName; type = "A";    value = mkIpRef h.hostName "ipv4_address";}
          {zone = z; name = h.hostName; type = "AAAA"; value = mkIpRef h.hostName "ipv6_address";}
        ]) zones
        # apex A/AAAA where a service claims the zone apex as a vhost
        ++ lib.concatMap (z: [
          {zone = z; name = "@"; type = "A";    value = mkIpRef h.hostName "ipv4_address";}
          {zone = z; name = "@"; type = "AAAA"; value = mkIpRef h.hostName "ipv6_address";}
        ]) (lib.filter (vh: lib.elem vh zones) vhosts)
        # service CNAMEs
        ++ map (vh: let z = zoneForHost vh; in
          {zone = z; name = lib.removeSuffix ".${z}" vh; type = "CNAME"; value = "${h.hostName}.${z}";}
        ) (lib.filter (vh:
          let z = zoneForHost vh;
          in z != null && vh != z && !hasPort vh && !isWildcard vh
        ) vhosts)
  ) hostEntries;

  recordAttrs = lib.listToAttrs (map (r: {
    name = lib.replaceStrings ["." "@"] ["-" "apex"] "${r.zone}-${r.name}-${lib.toLower r.type}";
    value = {inherit (r) zone name type value;};
  }) recordList);

  serverDataAttrs = lib.listToAttrs (map (h: {
    name = h.hostName;
    value = {name = h.hostName;};
  }) (lib.filter (h: h.hetznerEnabled) hostEntries));

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

        data.hcloud_server = serverDataAttrs;
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
