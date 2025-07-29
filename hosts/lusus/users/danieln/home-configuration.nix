{
  inputs,
  flake,
  ...
}: {
  imports = [
    flake.homeModules.common
    flake.homeModules.class-laptop
    inputs.gridx.home-module
  ];
}
