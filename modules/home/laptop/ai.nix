{ ... }: {
  flake.modules.home.laptop_ai = {pkgs, ...}: {
    home = {
      packages = with pkgs; [
        claude-code
        sox
      ];
    };
  };
}
