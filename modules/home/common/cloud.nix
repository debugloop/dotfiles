{
  pkgs,
  config,
  ...
}: {
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

  age.secrets.gh-token.file = ../../../secrets/gh-token.age;

  programs = {
    rbw.enable = true;
    gh = {
      enable = true;
      package = let
        gh-wrapped = pkgs.writeShellScriptBin "gh" ''
          export GITHUB_TOKEN="$(cat ${config.age.secrets.gh-token.path})"
          ${pkgs.gh}/bin/gh "''${@}"
        '';
      in
        gh-wrapped;
      settings = {
        version = 1;
        git_protocol = "ssh";
      };
    };
  };
}
