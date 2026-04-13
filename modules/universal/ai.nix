_: {
  flake.homeModules.ai = {pkgs, ...}: {
    programs.opencode.enable = true;
    home.packages = with pkgs; [github-copilot-cli];
  };
}
