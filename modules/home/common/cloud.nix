{pkgs, ...}: {
  home.persistence."/nix/persist" = {
    directories = [
      {
        directory = ".aws";
        mode = "0700";
      }
      {
        directory = ".config/rbw";
        mode = "0700";
      }
    ];
    files = [".netrc"];
  };

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
}
