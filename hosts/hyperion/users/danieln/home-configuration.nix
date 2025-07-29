{flake, ...}: {
  imports = [
    flake.homeModules.common
    flake.homeModules.class-server
  ];
}
