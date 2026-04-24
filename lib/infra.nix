{
  inputs,
  flake,
  ...
}: let
  inherit (inputs.nixpkgs) lib;

  # Storage box hosts (from keys/hosts/*.pub)
  hostNames =
    map (f: lib.removeSuffix ".pub" (baseNameOf f))
    (lib.filter (lib.hasSuffix ".pub") (lib.filesystem.listFilesRecursive ../keys/hosts));

  # Auth SSH keys (from keys/auth/*.pub)
  authKeys = lib.listToAttrs (map (path: {
    name = lib.removeSuffix ".pub" (baseNameOf path);
    value = builtins.readFile path;
  }) (lib.filesystem.listFilesRecursive ../keys/auth));

  # DNS zones and helpers
  dnsZones = ["danieln.de" "bugpara.de"];
  isWildcard = host: lib.hasPrefix "*." host;
  hasPort = host: lib.hasInfix ":" host;
  zoneForHost = host: lib.findFirst (z: lib.hasSuffix ".${z}" host) null dnsZones;

  hostEntries =
    lib.mapAttrsToList (_: cfg: {
      inherit (cfg.config.networking) hostName;
      hetznerEnabled = cfg.config.hetzner.enable or false;
      vhosts = builtins.attrNames (cfg.config.services.caddy.virtualHosts or {});
    })
    flake.nixosConfigurations;

  hetznerHosts = lib.filterAttrs (_: cfg: cfg.config.hetzner.enable or false) flake.nixosConfigurations;

  mkRecords =
    lib.concatMap (
      h:
        if !h.hetznerEnabled
        then []
        else let
          ref = attr: "\${hcloud_server.${h.hostName}.${attr}}";
        in
          lib.concatMap (z: [
            {
              zone = z;
              name = h.hostName;
              type = "A";
              value = ref "ipv4_address";
            }
            {
              zone = z;
              name = h.hostName;
              type = "AAAA";
              value = ref "ipv6_address";
            }
          ])
          dnsZones
          ++ lib.concatMap (z: [
            {
              zone = z;
              name = "@";
              type = "A";
              value = ref "ipv4_address";
            }
            {
              zone = z;
              name = "@";
              type = "AAAA";
              value = ref "ipv6_address";
            }
          ]) (lib.filter (vh: lib.elem vh dnsZones) h.vhosts)
          ++ map (
            vh: let
              z = zoneForHost vh;
            in {
              zone = z;
              name = lib.removeSuffix ".${z}" vh;
              type = "CNAME";
              value = "${h.hostName}.${z}.";
            }
          ) (lib.filter (vh: let
            z = zoneForHost vh;
          in
            z != null && vh != z && !hasPort vh && !isWildcard vh)
          h.vhosts)
    )
    hostEntries;

  mkRecordName = r: lib.replaceStrings ["." "@"] ["-" "apex"] "${r.zone}-${r.name}-${lib.toLower r.type}";
  mkZoneRecords = recs:
    lib.listToAttrs (map (r: {
        name = mkRecordName r;
        value = {
          zone = "\${data.hcloud_zone.${lib.replaceStrings ["."] ["-"] r.zone}.name}";
          inherit (r) name type value;
        };
      })
      recs);
  zoneAttrs = lib.listToAttrs (map (z: {
      name = lib.replaceStrings ["."] ["-"] z;
      value = {name = z;};
    })
    dnsZones);

  storageboxResources = {
    resource.random_password = lib.listToAttrs (map (h: {
        name = h;
        value = {
          length = 64;
          special = true;
          override_special = "^!$%/()=?+#-.,;:~*@{}_&";
          min_upper = 1;
          min_lower = 1;
          min_numeric = 1;
          min_special = 1;
        };
      })
      hostNames);
    resource.hcloud_storage_box_subaccount = lib.listToAttrs (map (h: {
        name = h;
        value = {
          storage_box_id = "\${var.storage_box_id}";
          name = h;
          home_directory = h;
          password = "\${random_password.${h}.result}";
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
    data.hcloud_storage_box.parent = {id = "\${var.storage_box_id}";};
    output.storagebox = {
      sensitive = true;
      value.accounts = lib.listToAttrs (map (h: {
          name = h;
          value = {
            host = "\${hcloud_storage_box_subaccount.${h}.server}";
            username = "\${hcloud_storage_box_subaccount.${h}.username}";
            password = "\${random_password.${h}.result}";
          };
        })
        hostNames);
    };
  };
  hetznerModules =
    [
      {
        terraform = {
          backend.local.path = "/etc/nixos/tf-state/all.tfstate";
          required_providers = {
            hcloud = {
              source = "hetznercloud/hcloud";
              version = "~> 1.59";
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
        provider.hcloud.token = "\${var.hcloud_token}";
      }
      {
        resource.hcloud_ssh_key =
          lib.mapAttrs (name: key: {
            inherit name;
            public_key = key;
          })
          authKeys;
      }
      {
        data.hcloud_zone = zoneAttrs;
        resource.hcloud_zone_record = mkZoneRecords mkRecords;
      }
      storageboxResources
      {
        output.addresses.value =
          lib.mapAttrs (name: _: {
            v4 = "\${hcloud_server.${name}.ipv4_address}";
            v6 = "\${hcloud_server.${name}.ipv6_address}";
          })
          hetznerHosts;
      }
    ]
    ++ lib.mapAttrsToList (_: cfg: cfg.config.hetzner.terranixConfig) hetznerHosts;
in {
  hetznerHostNames = hostNames;
  inherit hetznerModules;

  hetznerTerranix = pkgs:
    inputs.terranix.lib.terranixConfiguration {
      inherit pkgs;
      modules = hetznerModules;
    };
}
