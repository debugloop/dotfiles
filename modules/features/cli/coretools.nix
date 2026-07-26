_: {
  flake.modules.nixos.coretools = {
    config,
    inputs,
    pkgs,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      bridge-utils
      coreutils
      file
      mkpasswd
      nettools
      pciutils
      procps
      psmisc
      usbutils

      inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default

      efibootmgr
      xfsprogs
    ];

    documentation.man.cache.enable = false;

    environment.persistence."/nix/persist".users.${config.mainUser}.directories = [
      ".local/share/zoxide"
    ];
  };

  flake.modules.homeManager.coretools = {pkgs, ...}: {
    programs = {
      bat = {
        enable = true;
        config.theme = "ansi";
      };
      btop = {
        enable = true;
        settings = {
          color_theme = "TTY";
          theme_background = false;
        };
      };
      eza = {
        enable = true;
      };
      fzf = {
        enable = true;
        enableFishIntegration = true;
        historyWidget.fish.command = "";
      };
      htop.enable = true;
      lf = {
        enable = true;
        settings = {
          previewer = "${pkgs.writeScript "./previewer.sh" ''
            #!/bin/sh
            git log --pretty=format:'%an, %ad: %s' --date=relative -- $@
          ''}";
          cursorpreviewfmt = "";
          ratios = [1 1];
        };
      };
      zoxide.enable = true;
    };

    home = {
      sessionVariables.EZA_COLORS = "reset";
      packages = with pkgs; [
        bmon
        dmidecode
        dust
        fd
        gavin-bc
        lsof
        moreutils
        nmap
        pwgen
        ripgrep
        tcpdump
        unzip
        watch
        zip
      ];
    };
  };
}
