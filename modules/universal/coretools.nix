_: {
  flake.modules.nixos.coretools = {config, ...}: {
    environment.persistence."/nix/persist".users.${config.mainUser}.directories = [
      ".local/share/atuin"
      ".local/share/zoxide"
    ];
  };

  flake.modules.homeManager.coretools = {pkgs, ...}: {
    programs = {
      atuin = {
        enable = true;
        flags = [
          "--disable-up-arrow"
        ];
        settings = {
          secrets_filter = false;
          sync_frequency = "5m";
          enter_accept = false;
          keymap_mode = "vim-insert";
        };
      };
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
        enableFishIntegration = false;
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
        pwgen
        renameutils
        doggo
        dool
        dust
        entr
        fd
        ffmpeg
        gping
        jrnl
        miniserve
        nmap
        ripgrep
        tailspin
        tcpdump
        xan
      ];
    };
  };
}
