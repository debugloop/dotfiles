_: {
  flake.homeModules.laptop_ai = {pkgs, ...}: {
    home = {
      packages = with pkgs; [
        claude-code
        sox
        opencode
        github-copilot-cli
      ];
    };
  };
}
