_: {
  flake.modules.homeManager.ssh = {
    lib,
    inputs,
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
