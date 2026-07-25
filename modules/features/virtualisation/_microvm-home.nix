{
  config,
  lib,
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
    home.stateVersion = "25.11";

    programs = {
      fish = {
        enable = true;
        shellInit = config.microvm.extraInit;
        loginShellInit = "cd ${config.microvm.workspace}";
      };
      git.enable = true;
      home-manager.enable = true;
    };
  };
}
