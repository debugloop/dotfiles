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
  ];

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
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
      ZK_NOTEBOOK_DIR = "~/documents/notes";
      NODE_PATH = "${pkgs.typescript}/lib/node_modules";
    };

    file = {
      ".sqliterc".text = ''
        .mode column
        .headers on
        .separator ROW "\n"
        .nullvalue NULL
      '';
      ".ignore".text = ''
        vendor/
        go.mod
        go.sum
      '';
    };

    packages = with pkgs; [
      # tools
      gmailctl
      # nix
      age
      alejandra
      comma
      devenv
      inputs.agenix.packages.${pkgs.system}.default
      nh
      nix-tree
      nixd
      nvd
      # basics
      bmon
      curl
      dig
      dmidecode
      dogdns
      dool
      du-dust
      dyff
      entr
      fd
      ffmpeg
      gcc
      getopt
      git
      gitAndTools.git-absorb
      gitAndTools.git-machete
      gitAndTools.git-trim
      glibc
      gnumake
      highlight
      ijq
      jq
      lsof
      moreutils
      netcat-openbsd
      openssh
      pwgen
      renameutils
      ripgrep
      socat
      tokei
      unzip
      watch
      wget
      whois
      zip
      zk
      # networking
      gping
      miniserve
      nmap
      sshfs
      tcpdump
      # dev api
      grpcurl
      jwt-cli
      k6
      yq-go
      # dev languages
      jupyter
      lua-language-server
      luajit
      nodePackages_latest.yaml-language-server
      protobuf
      typescript
      typescript-language-server
      # dev general linters
      ast-grep
      buf
      codespell
      nodePackages_latest.prettier
      proselint
      stylua
      tree-sitter
      vale
      yamllint
      # dev debug
      protoscope
      rr
      # dev databases
      pgcli
      sqlite
      redis
      # dev cloud
      awscli2
      devspace
      ssm-session-manager-plugin
      kontemplate
      kubeconform
      kubectl
      kustomize
      # dev go
      delve
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
      protoc-gen-go
      protoc-gen-go-grpc
      # hardware (TODO: are those installed system-wide?)
      simple-scan
      powertop
      pulseaudio # TODO: should be installed by services
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
