{ ... }: {
  flake.modules.nixos.common_hetzner = {
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
        description = "Names of SSH keys to attach (managed by hetzner in lib)";
      };

      extraTerranixConfig = lib.mkOption {
        type = lib.types.attrs;
        default = {};
        description = "Additional Terranix configuration to merge";
      };

      terranixConfig = lib.mkOption {
        type = lib.types.attrs;
        readOnly = true;
        description = "Generated Terranix configuration for this host";
      };
    };

    config = lib.mkIf config.hetzner.enable (let
      hostName = config.networking.hostName;
      sshKeyRefs = map (name: "\${hcloud_ssh_key.${name}.id}") config.hetzner.sshKeyNames;
    in {
      hetzner.terranixConfig = lib.mkMerge [
        {
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
        }
        config.hetzner.extraTerranixConfig
      ];
    });
  };
}
