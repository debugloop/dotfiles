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
      modulesPath,
      ...
    }: {
      imports =
        (with inputs.self.modules.nixos; [
          server
          miniflux
          storagebox_mount
        ])
        ++ [
          (modulesPath + "/installer/scan/not-detected.nix")
          (modulesPath + "/profiles/qemu-guest.nix")
          inputs.disko.nixosModules.disko
        ];

      disko.devices = inputs.self.diskoConfigurations.roshar.disko.devices;

      nixpkgs.hostPlatform = "x86_64-linux";
      networking = {
        hostName = "roshar";
        domain = "danieln.de";
        useDHCP = true;
      };
      backup = {
        enable = true;
        storagebox = {
          host = "u564729-sub1.your-storagebox.de";
          user = "u564729-sub1";
        };
      };

      hetzner = {
        enable = true;
        serverType = "cx23";
        location = "nbg1";
        image = "debian-12";
        sshKeyNames = ["hyperion" "simmons"];
      };

      services.openssh.enable = true;
      storagebox_mount.enable = true;

      home-manager.users.danieln.home.stateVersion = "22.11";

      system.stateVersion = "24.11";
    };
  };
}
