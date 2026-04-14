_: {
  flake.modules.nixos.online = {config, ...}: {
    environment.persistence."/nix/persist".users.${config.mainUser}.directories = [
      {
        directory = ".aws";
        mode = "0700";
      }
      {
        directory = ".config/rbw";
        mode = "0700";
      }
    ];
  };

  flake.modules.homeManager.online = {pkgs, ...}: {
    home.packages = with pkgs; [
      awscli2
      gmailctl
      ssm-session-manager-plugin
      yt-dlp
    ];

    programs = {
      rbw.enable = true;
      gh = {
        enable = true;
        settings = {
          version = 1;
          git_protocol = "ssh";
        };
      };
    };
  };
}
