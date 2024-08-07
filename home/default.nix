{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nix-index-database.hmModules.nix-index
    ./colors.nix
    ./fish.nix
    ./git.nix
    ./helix.nix
    ./nvim
    ./starship.nix
    ./wayland
  ];

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  manual = {
    html.enable = true;
    json.enable = true;
  };

  home = {
    username = "danieln";
    homeDirectory = "/home/danieln";
    stateVersion = "22.11";
    sessionPath = [
      "$HOME/go/bin"
    ];
    sessionVariables = {
      EDITOR = "${pkgs.neovim}/bin/nvim";
      FLAKE = "/etc/nixos";
      MANPAGER = "nvim +Man!";
      HIGHLIGHT_STYLE = "base16/grayscale-dark";
      PAGER = "less -R --use-color -Dd+r -Du+b";
      ZK_NOTEBOOK_DIR = "/home/danieln/documents/notes";
      NODE_PATH = "${pkgs.typescript}/lib/node_modules";
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
      inputs.agenix.packages.x86_64-linux.default
      alejandra
      comma
      devenv
      inputs.home-manager.packages.x86_64-linux.default
      nh
      nil
      nixd
      nvd
      # basics
      difftastic
      getopt
      lsof
      moreutils
      netcat-openbsd
      openssh
      pcre
      pwgen
      socat
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
      dmidecode
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
      buf
      cargo
      codespell
      cutter
      delve
      devspace
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
      gotests
      gotestsum
      go-tools
      gotools
      highlight
      k6
      kontemplate
      kubeconform
      kubectl
      kustomize
      luajit
      lua-language-server
      nodePackages_latest.yaml-language-server
      pgcli
      nodePackages_latest.prettier
      proselint
      protobuf
      protoc-gen-go
      protoc-gen-go-grpc
      python3
      python3Packages.ipython
      redis
      rr
      sqlite
      ssm-session-manager-plugin
      stylua
      tcpdump
      tree-sitter
      typescript
      typescript-language-server
      vale
      yamllint
      # fun
      nms
      # hardware (TODO: are those installed system-wide?)
      powertop
      pulseaudio # TODO: should be installed by services
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
      extraConfig = ''
        PermitLocalCommand yes
        LocalCommand ${pkgs.libnotify}/bin/notify-send "%r@%h" "Connected to %h."
      '';
    };
  };
}
