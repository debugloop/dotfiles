_: {
  flake.modules.nixos.desktop = {
    config,
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

    # environment.systemPackages = with pkgs; [
    #   networkmanagerapplet # required system-wide for icons
    # ];

    services = {
      dbus.enable = true;
      gnome.gnome-keyring = {
        enable = true;
      };
      gvfs.enable = true;
    };

    security.pam.services = {
      login.enableGnomeKeyring = true;
    };

    environment.persistence."/nix/persist".users.${config.mainUser} = {
      directories = [
        {
          directory = ".local/share/keyrings";
          mode = "0700";
        }
      ];
    };

    home-manager.users.${config.mainUser}.imports = [inputs.self.modules.homeManager.desktop];
  };

  flake.modules.homeManager.desktop = {
    config,
    pkgs,
    ...
  }: {
    home = {
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        XDG_DESKTOP_DIR = config.home.homeDirectory;
        XDG_DOCUMENTS_DIR = "${config.home.homeDirectory}/documents";
        XDG_DOWNLOAD_DIR = "${config.home.homeDirectory}/downloads";
        XDG_PICTURES_DIR = "${config.home.homeDirectory}/pictures";
      };
      packages = with pkgs; [
        # ui, utils, system apps
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
        wl-clipboard-rs
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
      # network-manager-applet.enable = true;
      gnome-keyring.enable = true;
    };
  };
}
