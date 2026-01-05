{pkgs, ...}: {
  imports = [
    ./ai.nix
    ./applications.nix
    ./clipman.nix
    ./ghostty.nix
    ./kanshi.nix
    ./kitty.nix
    ./mako.nix
    ./niri.nix
    ./osd.nix
    ./swayidle.nix
    ./swaylock.nix
    ./waybar.nix
  ];

  gtk.enable = true; # applies generated configs

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
      zed-editor-fhs
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
    blueman-applet.enable = true;
    gnome-keyring.enable = true;
  };
}
