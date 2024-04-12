{ pkgs, inputs, ... }:

{
  imports = [
    inputs.nix-index-database.hmModules.nix-index
    ./colors.nix
    ./fish.nix
    ./git.nix
    ./helix.nix
    ./kitty.nix
    ./nvim
    #./ranger.nix
    ./starship.nix
    ./wayland
  ];

  services = {
    blueman-applet.enable = true;
    gnome-keyring.enable = true;
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = (_: true);
  };

  gtk.enable = true; # applies generated configs

  home = {
    username = "danieln";
    homeDirectory = "/home/danieln";
    pointerCursor = {
      package = "${pkgs.numix-cursor-theme}";
      name = "Numix-Cursor";
      gtk.enable = true; # generates gtk cursor config
    };
    stateVersion = "22.11";
    sessionPath = [
      "$HOME/go/bin"
    ];
    sessionVariables = {
      DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";
      EDITOR = "${pkgs.neovim}/bin/nvim";
      FLAKE = "/etc/nixos";
      GRIM_DEFAULT_DIR = "/home/danieln/pictures";
      GTK_THEME = "Arc-Darker";
      HIGHLIGHT_STYLE = "base16/grayscale-dark";
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
      PAGER = "less -R --use-color -Dd+r -Du+b";
      XDG_DESKTOP_DIR = "/home/danieln";
      XDG_DOCUMENTS_DIR = "/home/danieln/documents";
      XDG_DOWNLOAD_DIR = "/home/danieln/downloads";
      XDG_PICTURES_DIR = "/home/danieln/pictures";
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
      age
      comma
      deadnix
      inputs.agenix.packages.x86_64-linux.default
      inputs.nh.packages.x86_64-linux.default
      nil
      nvd
      # basics
      getopt
      lsof
      moreutils
      netcat-gnu
      openssh
      pcre
      pwgen
      unzip
      watch
      wget
      whois
      zip
      # apis
      curl
      grpcurl
      jq
      jwt-cli
      yq-go
      # cli utils
      ast-grep
      bmon
      dogdns
      dstat
      du-dust
      entr
      fd
      ijq
      gping
      miniserve
      nmap
      renameutils
      ripgrep
      sshfs
      tokei
      zk
      # cli for graphics
      ghostscript_headless
      graphviz
      imagemagick
      pdftk
      # dev
      awscli2
      cargo
      codespell
      delve
      docker-compose
      gcc
      git
      gitAndTools.git-absorb
      gitAndTools.git-trim
      glibc
      gnumake
      gofumpt
      goimports-reviser
      golangci-lint
      gopls
      gotags
      gotest
      gotestsum
      gotools
      highlight
      insomnia
      k6
      kontemplate
      kubeconform
      kubectl
      luajit
      lua-language-server
      marksman
      nodePackages_latest.yaml-language-server
      #postman
      proselint
      protobuf
      protoc-gen-go
      protoc-gen-go-grpc
      python3
      python3Packages.ipython
      redis
      rr
      sqlite
      stylua
      tcpdump
      tree-sitter
      vale
      yamllint
      # fun
      nms
      # hardware (TODO: are those installed system-wide?)
      powertop
      pulseaudio
      # keyboard
      dfu-util
      gcc-arm-embedded
      qmk
    ];
  };

  programs = {
    dircolors.enable = true;
    fzf.enable = true;
    gpg.enable = true;
    home-manager.enable = true;
    htop.enable = true;
    less.enable = true;
    rbw.enable = true;
    tmate.enable = true;
    zoxide.enable = true;
    atuin = {
      enable = true;
      flags = [
        "--disable-up-arrow"
      ];
      settings = {
        secrets_filter = false;
        sync_frequency = "5m";
        enter_accept = false;
        keymap_mode = "vim-normal";
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
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    eza = {
      enable = true;
    };
    gh = {
      enable = true;
      settings = {
        version = 1;
        git_protocol = "ssh";
      };
    };
    go = {
      enable = true;
      package = pkgs.go_1_22;
    };
    ssh = {
      enable = true;
      # extraConfig = ''
      # PermitLocalCommand yes
      # LocalCommand ${pkgs.libnotify}/bin/notify-send "%r@%h" "Connected to %h."
      # '';
    };
    wezterm = {
      enable = true;
      extraConfig = ''
        local wezterm = require 'wezterm'
        local config = {}
        if wezterm.config_builder then
          config = wezterm.config_builder()
        end

        -- under the hood
        config.enable_wayland = true

        -- fonts
        config.font = wezterm.font('FiraCode Nerd Font')
        config.font_size = 11.0

        -- visuals
        config.enable_tab_bar = false

        -- color
        config.force_reverse_video_cursor = true
        config.colors = {
            foreground = "#dcd7ba",
            background = "#1f1f28",

            cursor_bg = "#c8c093",
            cursor_fg = "#c8c093",
            cursor_border = "#c8c093",

            selection_fg = "#c8c093",
            selection_bg = "#2d4f67",

            scrollbar_thumb = "#16161d",
            split = "#16161d",

            ansi = { "#090618", "#c34043", "#76946a", "#c0a36e", "#7e9cd8", "#957fb8", "#6a9589", "#c8c093" },
            brights = { "#727169", "#e82424", "#98bb6c", "#e6c384", "#7fb4ca", "#938aa9", "#7aa89f", "#dcd7ba" },
            indexed = { [16] = "#ffa066", [17] = "#ff5d62" },
        }
        return config
      '';
    };
  };
}
