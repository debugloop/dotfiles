{ ... }: {
  flake.modules.nixos.laptop_desktop = {
    pkgs,
    inputs,
    ...
  }: {
    imports = [
      inputs.niri.nixosModules.niri
    ];

    services.niri-autoselect-portal.enable = true;

    programs = {
      niri = {
        enable = true;
        package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
      };
      thunar = {
        enable = true;
        plugins = with pkgs; [
          thunar-archive-plugin
          thunar-volman
        ];
      };
    };

    fonts.packages = with pkgs; [
      fira
      fira-code
      fira-code-symbols
      fira-go
      fira-math
      iosevka
      # nerd-fonts.fira-code
      # nerd-fonts.fira-mono
      # nerd-fonts.noto
      # nerd-fonts.iosevka
      nerd-fonts.symbols-only
      # noto-fonts
      # noto-fonts-monochrome-emoji
      # noto-fonts-lgc-plus
      roboto
      roboto-mono
    ];

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      config = {
        common = {
          default = [
            "gnome"
            "gtk"
          ];
          "org.freedesktop.impl.portal.FileChooser" = "gtk";
          "org.freedesktop.impl.portal.Access" = "gtk";
          "org.freedesktop.impl.portal.Notification" = "gtk";
          "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
        };
      };
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };

    environment.systemPackages = with pkgs; [
      networkmanagerapplet # required system-wide for icons
    ];

    services = {
      blueman.enable = true;
      gnome.gnome-keyring = {
        enable = true;
      };
      gvfs.enable = true;
      pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
        wireplumber.enable = true;
      };
      printing.enable = true;
    };

    services.speechd.enable = false;

    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "niri-session";
        user = "danieln";
      };
    };

    security = {
      pam.services = {
        swaylock = {};
        login.enableGnomeKeyring = true;
      };
      rtkit.enable = true; # for pipewire
    };

    backup.exclude = [
      "home/danieln/go" # golang cache
      "home/danieln/scratch"
      "home/danieln/downloads"
      "home/danieln/.local/share/Steam"
      "home/danieln/.thunderbird"
      "home/danieln/.config/google-chrome"
      "home/danieln/.config/Slack"
      "home/danieln/.mozilla"
      "home/danieln/code/**/.cache" # generic caches
      "home/danieln/code/**/.direnv" # direnv cached envs, can be 100s of MB
      "home/danieln/code/**/node_modules" # npm/pnpm/yarn deps, reproducible
      "home/danieln/code/**/target" # Rust/Cargo build artifacts
      "home/danieln/code/**/result" # Nix build result symlinks
      "home/danieln/code/**/result-*" # Nix multi-output result symlinks
    ];

    environment.persistence."/nix/persist" = {
      directories = [
        "/var/lib/bluetooth"
      ];
      users.danieln = {
        directories = [
          ".mozilla"
          ".thunderbird"
          ".config/google-chrome"
          ".config/Slack"
          ".config/Postman"
          ".config/qView"
          ".config/zed"
          ".local/share/zed"
          ".ts3client"
          ".local/share/Steam"
          ".local/state/wireplumber"
          ".config/gtk-3.0"
          {
            directory = ".local/share/keyrings";
            mode = "0700";
          }
        ];
        files = [
          ".config/spotify/prefs"
          ".config/spotify/Users/analogbyte-user/prefs"
        ];
      };
    };
  };
}
