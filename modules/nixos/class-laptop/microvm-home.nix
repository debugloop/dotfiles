{
  config,
  lib,
  pkgs,
  ...
}: {
  options.microvm = {
    extraInit = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra fish shellInit lines for this microVM.";
    };
    workspace = lib.mkOption {
      type = lib.types.str;
      description = "Absolute path to the workspace directory (auto-cd on login).";
    };
  };

  config = {
    home.username = "danieln";
    home.homeDirectory = "/home/danieln";

    programs.fish = {
      enable = true;
      shellInit = ''
        set -x CLAUDE_CONFIG_DIR /home/danieln/.claude
        ${config.microvm.extraInit}
      '';
      loginShellInit = "cd ${config.microvm.workspace}";
      shellAbbrs.c = "claude --dangerously-skip-permissions";
    };

    programs.git.enable = true;

    home.packages = [pkgs.claude-code];

    home.stateVersion = "25.11";
    programs.home-manager.enable = true;
  };
}
