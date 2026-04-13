_: {
  flake.modules.nixos.desktop = {
    pkgs,
    inputs,
    ...
  }: {
    programs.thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-volman
      ];
    };

    environment.systemPackages = with pkgs; [
      networkmanagerapplet # required system-wide for icons
    ];

    services = {
      gnome.gnome-keyring = {
        enable = true;
      };
      gvfs.enable = true;
    };

    security.pam.services = {
      login.enableGnomeKeyring = true;
    };

    backup.exclude = [
      "home/danieln/go" # golang cache
      "home/danieln/scratch"
      "home/danieln/downloads"
      "home/danieln/code/**/.cache" # generic caches
      "home/danieln/code/**/.direnv" # direnv cached envs, can be 100s of MB
      "home/danieln/code/**/node_modules" # npm/pnpm/yarn deps, reproducible
      "home/danieln/code/**/target" # Rust/Cargo build artifacts
      "home/danieln/code/**/result" # Nix build result symlinks
      "home/danieln/code/**/result-*" # Nix multi-output result symlinks
    ];

    environment.persistence."/nix/persist".users.danieln = {
      directories = [
        ".config/gtk-3.0"
        ".config/Postman"
        ".config/zed"
        ".local/share/zed"
        {
          directory = ".local/share/keyrings";
          mode = "0700";
        }
      ];
    };

    home-manager.sharedModules = [inputs.self.modules.homeManager.desktop];
  };

  flake.modules.homeManager.desktop = {pkgs, ...}: {
    gtk = {
      enable = true; # applies generated configs
      gtk4.theme = null;
    };

    home = {
      pointerCursor = {
        package = "${pkgs.numix-cursor-theme}";
        name = "Numix-Cursor";
        gtk.enable = true; # generates gtk cursor config
      };
      sessionVariables = {
        GTK_THEME = "Arc-Darker";
        NIXOS_OZONE_WL = "1";
        XDG_DESKTOP_DIR = "/home/danieln";
        XDG_DOCUMENTS_DIR = "/home/danieln/documents";
        XDG_DOWNLOAD_DIR = "/home/danieln/downloads";
        XDG_PICTURES_DIR = "/home/danieln/pictures";
      };
      packages = with pkgs; [
        # ui, utils, system apps
        arc-theme
        gnome-icon-theme
        grim
        hicolor-icon-theme
        libnotify.out
        pavucontrol
        pinentry-gnome3
        playerctl
        slurp
        wdisplays
        wev
        wl-mirror
        xdg-utils
        # cli apps with graphical deps
        imagemagick
        pdftk
        qmk
      ];
    };

    xdg = {
      configFile."electron25-flags.conf".text = ''
        --enable-features=WaylandWindowDecorations
        --ozone-platform-hint=auto
      '';

      mimeApps = {
        enable = true;
        defaultApplications = {
          "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
          "application/x-extension-htm" = "firefox.desktop";
          "application/x-extension-html" = "firefox.desktop";
          "application/x-extension-shtml" = "firefox.desktop";
          "application/x-extension-xht" = "firefox.desktop";
          "application/x-extension-xhtml" = "firefox.desktop";
          "application/xhtml+xml" = "firefox.desktop";
          "image/svg+xml" = "org.inkscape.Inkscape.desktop";
          "text/html" = "firefox.desktop";
          "x-scheme-handler/chrome" = "firefox.desktop";
          "x-scheme-handler/http" = "firefox.desktop";
          "x-scheme-handler/https" = "firefox.desktop";
        };
      };
    };

    services = {
      cliphist.enable = true;
      network-manager-applet.enable = true;
      gnome-keyring.enable = true;
    };
  };
}
