_: {
  flake.modules.homeManager.ssh = {pkgs, ...}: {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
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
        "hyperion" = {
          hostname = "hyperion";
          forwardAgent = true;
        };
      };
      extraConfig = ''
        PermitLocalCommand yes
        LocalCommand ${pkgs.libnotify}/bin/notify-send --category=ssh "%r@%h" "Connected to %h."
      '';
    };
  };
}
