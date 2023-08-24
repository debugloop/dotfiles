{ pkgs, ... }:

{
  imports = [
    # our windowmanager
    ./hyprland.nix
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
    obs-studio.enable = true;
    qutebrowser.enable = true;
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
    pinentry-emacs.gnome3
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
    wofi
    xdg-utils
  ];

  # TODO: does this work for any electron app?
  xdg.configFile."electron25-flags.conf".text = ''
    --enable-features=WaylandWindowDecorations
    --ozone-platform-hint=auto
  '';
}
