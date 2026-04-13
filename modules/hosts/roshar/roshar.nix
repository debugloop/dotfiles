{
  self,
  inputs,
  ...
}: {
  flake = {
    diskoConfigurations.roshar = {
      disko.devices = {
        disk.main = {
          type = "disk";
          device = "/dev/sda";
          content = {
            type = "gpt";
            partitions = {
              boot = {
                size = "1M";
                type = "EF02";
                priority = 1;
              };
              ESP = {
                size = "512M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "xfs";
                  mountpoint = "/nix";
                };
              };
            };
          };
        };
      };
    };

    nixosConfigurations.roshar = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
      };
      modules = [self.modules.nixos.roshar];
    };

    homeConfigurations."danieln@roshar" = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = {
        inherit inputs;
      };
      modules = with self.modules.homeManager; [danieln_headless server];
    };

    modules.nixos.roshar = {
      inputs,
      config,
      modulesPath,
      pkgs,
      ...
    }: {
      imports =
        (with inputs.self.modules.nixos; [
          server
          miniflux
        ])
        ++ [
          (modulesPath + "/installer/scan/not-detected.nix")
          (modulesPath + "/profiles/qemu-guest.nix")
          inputs.disko.nixosModules.disko
        ];

      disko.devices = inputs.self.diskoConfigurations.roshar.disko.devices;

      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "roshar";
      backup.enable = true;

      hetzner = {
        enable = true;
        serverType = "cx23";
        location = "nbg1";
        image = "debian-12";
        sshKeyNames = ["hyperion" "simmons"];
      };

      networking.useDHCP = true;
      services.openssh.enable = true;
      programs.fuse.userAllowOther = true;

      environment.systemPackages = [pkgs.sshfs pkgs.fuse3];
      systemd.tmpfiles.rules = [
        "d /mnt/storagebox 0755 root root -"
        "d /root/.ssh 0700 root root -"
        "f /root/.ssh/known_hosts 0644 root root -"
      ];

      systemd.services.storagebox-sshfs = let
        storageBox = import ./_storagebox.nix;
      in {
        description = "Storage Box SSHFS mount";
        after = ["network-online.target"];
        wants = ["network-online.target"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          Type = "simple";
          ExecStart = ''
            ${pkgs.sshfs}/bin/sshfs -f \
              -p 23 \
              -o IdentityFile=/etc/ssh/ssh_host_ed25519_key \
              -o IdentitiesOnly=yes \
              -o PreferredAuthentications=publickey \
              -o PasswordAuthentication=no \
              -o StrictHostKeyChecking=accept-new \
              -o UserKnownHostsFile=/root/.ssh/known_hosts \
              -o ServerAliveInterval=15 \
              -o ServerAliveCountMax=3 \
              -o reconnect \
              -o allow_other \
              -o uid=0 \
              -o gid=0 \
              -o umask=077 \
              -o noatime \
              ${storageBox.user}@${storageBox.host}:. /mnt/storagebox
          '';
          ExecStop = "${pkgs.fuse3}/bin/fusermount3 -u /mnt/storagebox";
          Restart = "on-failure";
          RestartSec = 2;
        };
      };

      home-manager.users.danieln = {
        home.stateVersion = "22.11";
        imports = with inputs.self.modules.homeManager; [danieln_headless server];
      };

      system.stateVersion = "24.11";

      users.users.root.openssh.authorizedKeys.keys =
        map
        (name: builtins.readFile (../../../keys/auth + "/${name}.pub"))
        config.hetzner.sshKeyNames;
    };
  };
}
