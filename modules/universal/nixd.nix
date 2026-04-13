_: {
  flake.modules.homeManager.nixd = {pkgs, ...}: {
    home.packages = [pkgs.nixd];
  };
}
