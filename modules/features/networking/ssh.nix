{lib, ...}: {
  options.flake.sshForwardAgentHosts = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "Hostnames for which SSH agent forwarding should be enabled.";
  };

  config.flake.modules.nixos.ssh = {config, ...}: {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "prohibit-password";
      };
    };

    environment.persistence."/nix/persist".users.${config.mainUser}.directories = [
      {
        directory = ".ssh";
        mode = "0700";
      }
    ];
  };

  config.flake.modules.homeManager.ssh = {
    inputs,
    lib,
    ...
  }: let
    forwardAgentHosts = inputs.self.sshForwardAgentHosts;
    forwardAgentBlocks = lib.listToAttrs (map (host: {
        name = host;
        value = {
          HostName = host;
          ForwardAgent = true;
        };
      })
      forwardAgentHosts);
  in {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings =
        {
          "*" = {
            ForwardAgent = false;
            AddKeysToAgent = "no";
            Compression = false;
            ServerAliveInterval = 0;
            ServerAliveCountMax = 3;
            HashKnownHosts = false;
            UserKnownHostsFile = "~/.ssh/known_hosts";
            ControlMaster = "no";
            ControlPath = "~/.ssh/master-%r@%n:%p";
            ControlPersist = "no";
          };
        }
        // forwardAgentBlocks;
    };
  };
}
