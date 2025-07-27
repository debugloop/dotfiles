{
  inputs,
  flake,
  ...
}: {
  imports = [
    flake.homeModules.shared
    flake.homeModules.graphical
    inputs.gridx.home-module
  ];
}
