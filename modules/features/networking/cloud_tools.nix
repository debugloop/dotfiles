_: {
  flake.modules.nixos.cloud_tools = {config, ...}: {
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

  flake.modules.homeManager.cloud_tools = {pkgs, ...}: {
    home.packages = with pkgs; [
      awscli2
      gmailctl
      ssm-session-manager-plugin
      yt-dlp-light
    ];

    programs.rbw.enable = true;
  };
}
