_: {
  flake.modules.homeManager.ai = {pkgs, ...}: {
    programs.opencode.enable = true;
    home.packages = with pkgs; [github-copilot-cli];
  };
}
