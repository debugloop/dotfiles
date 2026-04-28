_: {
  flake.modules.nixos.hetzner = {
    config,
    inputs,
    lib,
    authKeysDir,
    ...
  }: let
    # Dynamically discover all auth SSH key names from authKeysDir
    authKeyNames =
      map (f: lib.removeSuffix ".pub" (baseNameOf f))
      (lib.filter (lib.hasSuffix ".pub") (lib.filesystem.listFilesRecursive authKeysDir));
  in {
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
        default = authKeyNames;
        description = "Names of SSH keys to attach (defaults to all keys in authKeysDir)";
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
      inherit (config.networking) hostName;
      sshKeyRefs = map (name: "\${hcloud_ssh_key.${name}.id}") config.hetzner.sshKeyNames;
    in {
      hetzner.terranixConfig = lib.mkMerge [
        {
          resource.hcloud_server.${hostName} = {
            name = hostName;
            server_type = config.hetzner.serverType;
            inherit (config.hetzner) image;
            inherit (config.hetzner) location;
            ssh_keys = sshKeyRefs;
            public_net = {
              ipv4_enabled = true;
              ipv6_enabled = true;
            };
          };
        }
        config.hetzner.extraTerranixConfig
      ];

      users.users.root.openssh.authorizedKeys.keys =
        map
        (name: builtins.readFile (inputs.self + "/keys/auth/${name}.pub"))
        config.hetzner.sshKeyNames;
    });
  };
}
