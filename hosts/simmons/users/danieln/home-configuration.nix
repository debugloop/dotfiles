{flake, ...}: {
  imports = [
    flake.homeModules.shared
    flake.homeModules.graphical
  ];
}
