_: {
  flake.modules.homeManager.git_tools = {pkgs, ...}: {
    home.packages = with pkgs; [
      git-absorb
      git-trim
      jj-pre-push
      jjui
      jujutsu
      mergiraf
      tig
    ];

    programs = {
      delta.enableJujutsuIntegration = true;
      git.settings.trim.confirm = false;
      jujutsu = {
        enable = true;
        settings.user = {
          email = "git@danieln.de";
          name = "Daniel Nägele";
        };
      };
    };
  };
}
