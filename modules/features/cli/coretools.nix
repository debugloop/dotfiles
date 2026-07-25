_: {
  flake.modules.nixos.coretools = {config, ...}: {
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
        dust
        fd
        nmap
        pwgen
        ripgrep
        tcpdump
      ];
    };
  };
}
