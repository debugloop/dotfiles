{...}: {
  flake.nixosModules.laptop_microvm = {
    config,
    inputs,
    lib,
    pkgs,
    ...
  }: let
    microvmBase = import ./_microvm-base.nix;
  in {
    options.codingVmsExternalInterface = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Host network interface used for microVM NAT (e.g. wlan0, enp3s0).";
    };

    options.codingVms = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {type = lib.types.str;};
          workspace = lib.mkOption {type = lib.types.str;};
          extraInit = lib.mkOption {
            type = lib.types.lines;
            default = "";
          };
        };
      });
      default = [];
      description = "List of coding microVMs to define on this host.";
    };

    imports = [inputs.microvm.nixosModules.host];

    config = lib.mkIf (config.codingVms != []) {
      # Bridge interface — managed by systemd-networkd alongside NetworkManager
      systemd.network.enable = true;
      systemd.network.netdevs."20-microbr".netdevConfig = {
        Kind = "bridge";
        Name = "microbr";
      };
      systemd.network.networks."20-microbr" = {
        matchConfig.Name = "microbr";
        addresses = [{Address = "192.168.83.1/24";}];
        networkConfig.ConfigureWithoutCarrier = true;
      };
      systemd.network.networks."21-microvm-tap" = {
        matchConfig.Name = "microvm*";
        networkConfig.Bridge = "microbr";
      };

      # Keep NetworkManager away from bridge/tap interfaces
      networking.networkmanager.unmanaged = [
        "microbr"
        "interface-name:microvm*"
      ];

      networking.nat = {
        enable = true;
        internalInterfaces = ["microbr"];
        externalInterface = config.codingVmsExternalInterface;
      };

      # Persist VM disk images and workspaces across reboots (impermanence: / is tmpfs)
      environment.persistence."/nix/persist".directories = [
        "/var/lib/microvms"
      ];
      environment.persistence."/nix/persist".users.danieln.directories =
        map (vm: lib.removePrefix "/home/danieln/" vm.workspace) config.codingVms;
      backup.exclude = ["var/lib/microvms"];

      # Create workspace dirs and generate SSH host keys on activation
      system.activationScripts = lib.listToAttrs (map (vm: {
          name = "microvm-${vm.name}-setup";
          value = {
            text = ''
              install -d -m 0755 -o danieln -g users ${vm.workspace}
              install -d -m 0700 -o danieln -g users ${vm.workspace}/ssh-host-keys
              if [ ! -f ${vm.workspace}/ssh-host-keys/ssh_host_ed25519_key ]; then
                ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -N "" \
                  -f ${vm.workspace}/ssh-host-keys/ssh_host_ed25519_key
                chown danieln:users \
                  ${vm.workspace}/ssh-host-keys/ssh_host_ed25519_key \
                  ${vm.workspace}/ssh-host-keys/ssh_host_ed25519_key.pub
              fi
            '';
            deps = ["users" "groups"];
          };
        })
        config.codingVms);

      # Generate microvm.vms.* entries from the codingVms option
      microvm.vms = lib.listToAttrs (lib.imap0 (index: vm: {
          name = vm.name;
          value = {
            autostart = false;
            config = {
              imports = [
                inputs.microvm.nixosModules.microvm
                (microvmBase (vm
                  // {
                    inherit inputs;
                    ipAddress = "192.168.83.${toString (index + 2)}";
                    tapId = "microvm${toString (index + 2)}";
                    mac = "02:00:00:00:00:${lib.fixedWidthString 2 "0" (lib.toHexString (index + 2))}";
                    vsockCid = index + 3;
                  }))
              ];
            };
          };
        })
        config.codingVms);
    };
  };
}
