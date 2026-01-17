{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nix-index-database.homeModules.nix-index
    ./cloud.nix
    ./colors.nix
    ./development.nix
    ./extra.nix
    ./fish.nix
    ./git.nix
    ./helix.nix
    ./nix.nix
    ./nvim
    ./starship.nix
  ];

  age.identityPaths = ["/home/danieln/.ssh/agenix"];

  home = {
    username = "danieln";
    homeDirectory = "/home/danieln";
    stateVersion = "22.11";
    sessionVariables = {
      HIGHLIGHT_STYLE = "base16/grayscale-dark";
      PAGER = "less -R --use-color -Dd+r -Du+b";
    };
    packages = with pkgs; [
      gavin-bc
      curl
      dig
      dmidecode
      gnumake
      highlight
      lsof
      moreutils
      netcat-openbsd
      openssh
      pwgen
      renameutils
      socat
      sshfs
      unzip
      watch
      wget
      whois
      zip
    ];
  };

  programs = {
    dircolors.enable = true;
    gpg.enable = true;
    less.enable = true;
    ssh = {
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
