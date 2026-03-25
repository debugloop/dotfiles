{
  config,
  lib,
  ...
}: {
  options.hetzner = {
    enable = lib.mkEnableOption "Hetzner Cloud provisioning";

    serverType = lib.mkOption {
      type = lib.types.str;
      default = "cx23";
    };

    location = lib.mkOption {
      type = lib.types.str;
      default = "nbg1";
    };

    image = lib.mkOption {
      type = lib.types.str;
      default = "debian-12";
    };

    sshKeyNames = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Names of existing SSH keys to attach (managed by hetzner-basics)";
    };

    dnsZone = lib.mkOption {
      type = lib.types.str;
      description = "DNS zone name (must exist in hetzner-basics)";
    };

    extraTerranixConfig = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Additional Terranix configuration to merge";
    };

    # ADD THIS OPTION
    terranixConfig = lib.mkOption {
      type = lib.types.attrs;
      readOnly = true;
      description = "Generated Terranix configuration for this host";
    };
  };

  config = lib.mkIf config.hetzner.enable (let
    hostName = config.networking.hostName;
    zone = config.hetzner.dnsZone;
    zoneKey = lib.replaceStrings ["."] ["-"] zone;
    keyNames = config.hetzner.sshKeyNames;

    keyDataSources = lib.listToAttrs (map (name: {
        inherit name;
        value = {name = name;};
      })
      keyNames);

    sshKeyRefs = map (name: "\${data.hcloud_ssh_key.${name}.id}") keyNames;

  in {
    # SET THE OPTION VALUE HERE
    hetzner.terranixConfig = lib.mkMerge [
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

        data.hcloud_ssh_key = keyDataSources;
        data.hcloud_zone.${zoneKey} = {
          name = zone;
        };


        resource.hcloud_server.${hostName} = {
          name = hostName;
          server_type = config.hetzner.serverType;
          image = config.hetzner.image;
          location = config.hetzner.location;
          ssh_keys = sshKeyRefs;
          public_net = {
            ipv4_enabled = true;
            ipv6_enabled = true;
          };
        };

        resource.hcloud_zone_record."${hostName}-${zoneKey}-a" = {
          zone = zone;
          name = hostName;
          type = "A";
          value = "\${hcloud_server.${hostName}.ipv4_address}";
        };

        resource.hcloud_zone_record."${hostName}-${zoneKey}-aaaa" = {
          zone = zone;
          name = hostName;
          type = "AAAA";
          value = "\${hcloud_server.${hostName}.ipv6_address}";
        };

        output."${hostName}_ip" = {
          value = "\${hcloud_server.${hostName}.ipv4_address}";
        };
      }
      config.hetzner.extraTerranixConfig
    ];
  });
}
