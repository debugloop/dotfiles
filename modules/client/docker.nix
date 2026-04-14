_: {
  flake.modules.nixos.docker = {
    config,
    pkgs,
    ...
  }: {
    virtualisation = {
      docker = {
        enable = false;
        rootless = {
          enable = true;
          setSocketVariable = true;
          daemon.settings = {
            bip = "10.200.0.1/24";
            default-address-pools = [
              {
                base = "10.201.0.0/16";
                size = 24;
              }
              {
                base = "10.202.0.0/16";
                size = 24;
              }
            ];
          };
        };
      };
    };

    # Use pasta instead of slirp4netns for better DNS handling
    # Pasta auto-discovers DNS from /etc/resolv.conf by default via --dns-host
    systemd.user.services.docker = {
      path = [pkgs.passt];
      environment = {
        DOCKERD_ROOTLESS_ROOTLESSKIT_NET = "pasta";
        DOCKERD_ROOTLESS_ROOTLESSKIT_PORT_DRIVER = "implicit";
        # Use Cloudflare DNS for pasta (works on any network)
        # Containers don't need split DNS, so public resolver is fine
        DOCKERD_ROOTLESS_ROOTLESSKIT_PASTA_OPTIONS = "--dns-host 1.1.1.1";
      };
    };
    networking.firewall = {
      checkReversePath = "loose";
    };

    environment = {
      systemPackages = [pkgs.passt];
      # https://github.com/NixOS/nixpkgs/issues/231191#issuecomment-1664053176
      etc."resolv.conf".mode = "direct-symlink";
      persistence."/nix/persist" = {
        directories = [
          "/var/lib/docker"
        ];
        users.${config.mainUser}.directories = [
          ".local/share/docker"
        ];
      };
    };

    backup.exclude = [
      "var/lib/docker"
      "home/${config.mainUser}/.local/share/docker"
    ];
  };
}
