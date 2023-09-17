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
    ./wayland
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
      yq
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
      clang
      codespell
      delve
      docker-compose
      git
      gitAndTools.git-absorb
      gitAndTools.git-trim
      gitlint
      glibc
      gnumake
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
      tree-sitter
      vale
      yamllint
      # fun
      nms
      # hardware (TODO: are those installed system-wide?)
      powertop
      pulseaudio
    ];
  };

  programs = {
    dircolors.enable = true;
    fzf.enable = true;
    gh.enable = true;
    gpg.enable = true;
    home-manager.enable = true;
    htop.enable = true;
    less.enable = true;
    rbw.enable = true;
    tealdeer.enable = true;
    tmate.enable = true;
    zoxide.enable = true;
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
      enableAliases = true;
    };
    go = {
      enable = true;
      package = pkgs.go_1_21;
    };
    ssh = {
      enable = true;
      extraConfig = '' 
      PermitLocalCommand yes
      LocalCommand ${pkgs.libnotify}/bin/notify-send "%r@%h" "Connected to %h."
      '';
    };
  };
}
