{flake, ...}: {
  imports = [
    flake.homeModules.shared
    flake.homeModules.headless
  ];
}
