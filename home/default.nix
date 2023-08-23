{ pkgs, inputs, ... }:

{
  imports = [
    inputs.nix-index-database.hmModules.nix-index
    ./colors.nix
    ./fish.nix
    ./git.nix
    #./helix.nix
    ./kitty.nix
    ./nvim
    #./ranger.nix
    ./starship.nix
    ./sway
    ./hyprland.nix
  ];

  services.blueman-applet.enable = true;

  home = {
    username = "danieln";
    homeDirectory = "/home/danieln";
    stateVersion = "22.11";
    sessionPath = [
      "$HOME/go/bin"
    ];
    sessionVariables = {
      EDITOR = "${pkgs.neovim}/bin/nvim";
      PAGER = "less -R --use-color -Dd+r -Du+b";
      HIGHLIGHT_STYLE = "base16/grayscale-dark";
      DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";
      XDG_DESKTOP_DIR = "/home/danieln";
      XDG_DOWNLOAD_DIR = "/home/danieln/downloads";
      XDG_PICTURES_DIR = "/home/danieln/pictures";
      GRIM_DEFAULT_DIR = "/home/danieln/pictures";
      XDG_DOCUMENTS_DIR = "/home/danieln/documents";
      ZK_NOTEBOOK_DIR = "/home/danieln/documents/notes";
    };

    file.".sqliterc".text = ''
      .mode column
      .headers on
      .separator ROW "\n"
      .nullvalue NULL
    '';

    file.".rgignore".text = ''
      go.mod
      go.sum
    '';

    packages = with pkgs; [
      # nix
      comma
      deadnix
      inputs.agenix.packages.x86_64-linux.default
      nil
      nvd
      # crypto
      age
      # cli utils
      ast-grep
      bmon
      dogdns
      dstat
      du-dust
      entr
      fd
      ijq
      miniserve
      nmap
      renameutils
      ripgrep
      sshfs
      tokei
      zk
      # apis
      curl
      gping
      grpcurl
      jq
      jwt-cli
      yq
      # basics
      getopt
      lsof
      netcat-gnu
      openssh
      pcre
      pwgen
      unzip
      watch
      wget
      whois
      # fun
      nms
      # graphical
      arc-theme
      cinnamon.nemo
      filezilla
      gimp
      gnome.eog
      gnome.evince
      gnome-icon-theme
      google-chrome
      grim
      hicolor-icon-theme
      inkscape
      kanshi
      libnotify.out
      libreoffice
      mako
      pinentry-emacs.gnome3
      playerctl
      python311Packages.managesieve
      slack
      slurp
      spotify
      teamspeak_client
      virt-manager
      vlc
      wofi
      xdg-utils
      # cli image tools
      ghostscript_headless
      graphviz
      imagemagick
      pdftk
      # hardware
      easyeffects
      pavucontrol
      powertop
      pulseaudio
      # dev
      awscli2
      cargo
      clang
      codespell
      delve
      docker-compose
      git
      gitAndTools.git-absorb
      gitlint
      glibc
      gnumake
      go
      golangci-lint
      gopls
      gotags
      gotest
      gotools
      highlight
      insomnia
      k6
      kubectl
      lua-language-server
      marksman
      nodePackages_latest.yaml-language-server
      postman
      proselint
      python3
      python3Packages.ipython
      redis
      sqlite
      stylua
      tcpdump
      vale
      wireshark
      yamllint
    ];
  };

  programs = {
    btop.enable = true;
    dircolors.enable = true;
    fzf.enable = true;
    firefox.enable = true;
    gh.enable = true;
    go.enable = true;
    gpg.enable = true;
    home-manager.enable = true;
    htop.enable = true;
    less.enable = true;
    mpv.enable = true;
    nix-index.enable = true;
    obs-studio.enable = true;
    qutebrowser.enable = true;
    rbw.enable = true;
    rofi.enable = true;
    tealdeer.enable = true;
    tmate.enable = true;
    zoxide.enable = true;
    bat = {
      enable = true;
      config.theme = "ansi";
    };
    broot = {
      enable = true;
      settings = {
        modal = true;
        verbs = [
          {
            key = "enter";
            execution = ":open_leave";
          }
          {
            key = "ctrl-enter";
            execution = ":open_stay";
          }
          {
            key = "ctrl-e";
            execution = "$EDITOR {file}";
          }
        ];
      };
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    exa = {
      enable = true;
      enableAliases = true;
    };
    lf = {
      enable = true;
      settings = {
        drawbox = true;
      };
      keybindings = {
        D = "delete";
      };
      previewer.source = pkgs.writeShellScript "pv.sh" ''
        #!/bin/sh

        case "$1" in
            *.tar*) tar tf "$1";;
            *.zip) unzip -l "$1";;
            *.rar) unrar l "$1";;
            *.7z) 7z l "$1";;
            *.pdf) pdftotext "$1" -;;
            *) highlight -O ansi "$1" || cat "$1";;
        esac
      '';
    };
    ssh = {
      enable = true;
      extraConfig = '' 
      PermitLocalCommand yes
      LocalCommand ${pkgs.libnotify}/bin/notify-send "%r@%h" "Connected to %h."
      '';
    };
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = "org.firefox.firefox.desktop";
    "x-scheme-handler/http" = "org.firefox.firefox.desktop";
    "x-scheme-handler/https" = "org.firefox.firefox.desktop";
    "x-scheme-handler/unknown" = "org.firefox.firefox.desktop";
  };
}
