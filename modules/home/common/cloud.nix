{pkgs, ...}: {
  home.packages = with pkgs; [
    awscli2
    gmailctl
    ssm-session-manager-plugin
    yt-dlp
  ];

  programs = {
    rbw.enable = true;
    tmate.enable = true;
    granted.enable = true;
    gh = {
      enable = true;
      settings = {
        version = 1;
        git_protocol = "ssh";
      };
    };
  };
}
