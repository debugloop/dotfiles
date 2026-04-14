_: {
  flake.modules.homeManager.ssh = {
    pkgs,
    lib,
    inputs,
    ...
  }: let
    forwardAgentHosts = inputs.self.sshForwardAgentHosts;
    forwardAgentBlocks = lib.listToAttrs (map (host: {
        name = host;
        value = {
          hostname = host;
          forwardAgent = true;
        };
      })
      forwardAgentHosts);
  in {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks =
        {
          "*" = {
            forwardAgent = false;
            addKeysToAgent = "no";
            compression = false;
            serverAliveInterval = 0;
            serverAliveCountMax = 3;
            hashKnownHosts = false;
            userKnownHostsFile = "~/.ssh/known_hosts";
            controlMaster = "no";
            controlPath = "~/.ssh/master-%r@%n:%p";
            controlPersist = "no";
          };
        }
        // forwardAgentBlocks;
      extraConfig = ''
        PermitLocalCommand yes
        LocalCommand ${pkgs.libnotify}/bin/notify-send --category=ssh "%r@%h" "Connected to %h."
      '';
    };
  };
}
