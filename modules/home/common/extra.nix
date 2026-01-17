{pkgs, ...}: {
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
    fzf.enable = true;
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
      doggo
      dool
      dust
      entr
      fd
      ffmpeg
      gping
      miniserve
      nmap
      ripgrep
      tailspin
      tcpdump
      xan
    ];
  };
}
