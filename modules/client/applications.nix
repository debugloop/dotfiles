_: {
  flake.modules.nixos.applications = _: {
    backup.exclude = [
      "home/danieln/.local/share/Steam"
      "home/danieln/.thunderbird"
      "home/danieln/.config/google-chrome"
      "home/danieln/.config/Slack"
      "home/danieln/.mozilla"
    ];

    environment.persistence."/nix/persist".users.danieln = {
      directories = [
        ".mozilla"
        ".thunderbird"
        ".config/google-chrome"
        ".config/Slack"
        ".config/qView"
        ".ts3client"
        ".local/share/Steam"
      ];
      files = [
        ".config/spotify/prefs"
        ".config/spotify/Users/analogbyte-user/prefs"
      ];
    };
  };

  flake.modules.homeManager.applications = {
    pkgs,
    config,
    ...
  }: {
    home = {
      sessionVariables = {
        DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";
        MOZ_ENABLE_WAYLAND = "1";
      };
      packages = with pkgs; [
        abiword
        dune3d
        gimp
        gnumeric
        google-chrome
        inkscape
        obsidian
        qview
        spotify
        wireshark
        zathura
        teamspeak6-client
        transmission_4-gtk
        audacity
      ];
    };

    programs = {
      firefox.enable = true;
      mpv.enable = true;
      wofi = {
        enable = true;
        settings = {
          run-always_parse_args = true;
        };
        style = ''
          window {
            border: 0px;
            border-radius: 2em;
            font-family: monospace;
            font-size: 15px;
          }

          #outer-box {
            margin: 0px;
            color: #${config.colors.foreground};
            background: transparent;
          }

          #scroll {
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

          #entry:selected {
            background-color: #${config.colors.blue};
          }
        '';
      };
    };
  };
}
