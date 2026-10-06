_: {
  flake.modules.nixos.docker = {config, ...}: {
    users.users.${config.mainUser}.extraGroups = ["docker"];

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

    networking.firewall = {
      checkReversePath = "loose";
    };

    environment = {
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
