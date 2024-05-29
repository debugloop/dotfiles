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
    wezterm = {
      enable = true;
      extraConfig = ''
        local wezterm = require 'wezterm'
        local config = {}
        if wezterm.config_builder then
          config = wezterm.config_builder()
        end

        -- under the hood
        config.enable_wayland = true

        -- fonts
        config.font = wezterm.font('FiraCode Nerd Font')
        config.font_size = 11.0
        config.freetype_load_target = 'Light'
        config.freetype_render_target = 'HorizontalLcd'
        config.underline_position = -2

        -- visuals
        config.enable_tab_bar = false

        -- color
        config.force_reverse_video_cursor = true
        config.colors = {
            foreground = "#dcd7ba",
            background = "#1f1f28",

            cursor_bg = "#c8c093",
            cursor_fg = "#c8c093",
            cursor_border = "#c8c093",

            selection_fg = "#c8c093",
            selection_bg = "#2d4f67",

            scrollbar_thumb = "#16161d",
            split = "#16161d",

            ansi = { "#090618", "#c34043", "#76946a", "#c0a36e", "#7e9cd8", "#957fb8", "#6a9589", "#c8c093" },
            brights = { "#727169", "#e82424", "#98bb6c", "#e6c384", "#7fb4ca", "#938aa9", "#7aa89f", "#dcd7ba" },
            indexed = { [16] = "#ffa066", [17] = "#ff5d62" },
        }
        return config
      '';
    };
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
