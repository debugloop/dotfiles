{ pkgs, config, ... }:

{
  imports = [
    # our windowmanager
    ./sway.nix
    # auxiliary services
    ./avizo.nix
    ./clipman.nix
    ./kanshi.nix
    ./mako.nix
    ./swayidle.nix
    ./swaylock.nix
    ./waybar.nix
  ];

  programs = {
    firefox.enable = true;
    mpv.enable = true;
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        #obs-backgroundremoval
      ];
    };
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

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "org.firefox.firefox.desktop";
      "x-scheme-handler/http" = "org.firefox.firefox.desktop";
      "x-scheme-handler/https" = "org.firefox.firefox.desktop";
      "x-scheme-handler/unknown" = "org.firefox.firefox.desktop";
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

  # TODO: does this work for any electron app?
  xdg.configFile."electron25-flags.conf".text = ''
    --enable-features=WaylandWindowDecorations
    --ozone-platform-hint=auto
  '';
}
