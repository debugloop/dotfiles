_: {
  flake.modules.nixos.applications = {
    config,
    inputs,
    ...
  }: {
    backup.exclude = [
      "home/${config.mainUser}/.local/share/Steam"
      "home/${config.mainUser}/.thunderbird"
      "home/${config.mainUser}/.config/google-chrome"
      "home/${config.mainUser}/.config/Slack"
      "home/${config.mainUser}/.mozilla"
    ];

    environment.persistence."/nix/persist".users.${config.mainUser} = {
      directories = [
        ".mozilla"
        ".thunderbird"
        ".config/google-chrome"
        ".config/Postman"
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

    home-manager.users.${config.mainUser}.imports = [inputs.self.modules.homeManager.applications];
  };

  flake.modules.homeManager.applications = {pkgs, ...}: {
    home = {
      sessionVariables = {
        DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";
        MOZ_ENABLE_WAYLAND = "1";
      };
      packages = with pkgs; [
        abiword
        dune3d
        ffmpeg-headless
        gimp
        gnumeric
        google-chrome
        inkscape
        nmgui
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
      mpv = {
        enable = true;
        package = pkgs.mpv.override {yt-dlp = pkgs.yt-dlp-light;};
      };
    };
  };
}
