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
    home = {
      username = "danieln";
      homeDirectory = "/home/danieln";
      packages = [pkgs.claude-code];
      stateVersion = "25.11";
    };

    programs = {
      fish = {
        enable = true;
        shellInit = ''
          set -x CLAUDE_CONFIG_DIR /home/danieln/.claude
          ${config.microvm.extraInit}
        '';
        loginShellInit = "cd ${config.microvm.workspace}";
        shellAbbrs.c = "claude --dangerously-skip-permissions";
      };
      git.enable = true;
      home-manager.enable = true;
    };
  };
}
