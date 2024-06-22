{ pkgs, config, ... }:

{
  imports = [
    # our windowmanager
    ./sway.nix
    ./river
    # auxiliary services
    ./avizo.nix
    ./clipman.nix
    ./kanshi.nix
    ./kitty.nix
    ./mako.nix
    ./swayidle.nix
    ./swaylock.nix
    ./waybar.nix
    ./wezterm
  ];

  gtk.enable = true; # applies generated configs

  home = {
    pointerCursor = {
      package = "${pkgs.numix-cursor-theme}";
      name = "Numix-Cursor";
      gtk.enable = true; # generates gtk cursor config
    };
    sessionVariables = {
      DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";
      GRIM_DEFAULT_DIR = "/home/danieln/pictures";
      GTK_THEME = "Arc-Darker";
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
      XDG_DESKTOP_DIR = "/home/danieln";
      XDG_DOCUMENTS_DIR = "/home/danieln/documents";
      XDG_DOWNLOAD_DIR = "/home/danieln/downloads";
      XDG_PICTURES_DIR = "/home/danieln/pictures";
    };
  };

  xdg = {
    # TODO: does this work for any electron app?
    configFile."electron25-flags.conf".text = ''
      --enable-features=WaylandWindowDecorations
      --ozone-platform-hint=auto
    '';

    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "org.firefox.firefox.desktop";
        "x-scheme-handler/http" = "org.firefox.firefox.desktop";
        "x-scheme-handler/https" = "org.firefox.firefox.desktop";
        "x-scheme-handler/unknown" = "org.firefox.firefox.desktop";
      };
    };
  };

  services = {
    blueman-applet.enable = true;
    gnome-keyring.enable = true;
  };

  programs = {
    firefox.enable = true;
    mpv.enable = true;
    qutebrowser.enable = true;
    wofi = {
      enable = true;
      settings = {
        run-always_parse_args = true;
      };
      style = ''
        window {
          border: 0px;
          border-radius: 10px;
          font-family: monospace;
          font-size: 15px;
        }

        #outer-box {
          margin: 0px;
          color: #${config.colors.foreground};
          background-color: #${config.colors.background};
        }

        #input {
          border:  0px;
          margin: 0px;
          border-radius: 10px 10px 0px 0px;
          padding: 10px;
          font-size: 22px;
          background-color: #${config.colors.light_bg};
        }

        #text {
          padding: 2px 2px 2px 10px;
        }
      '';
    };
  };

  home.packages = with pkgs; [
    arc-theme
    cinnamon.nemo
    easyeffects
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
    pavucontrol
    pinentry-gnome3
    playerctl
    python311Packages.managesieve
    slack
    slurp
    spotify
    teamspeak_client
    virt-manager
    vlc
    wdisplays
    wev
    wireshark
    wl-mirror
    xdg-utils
  ];
}
