{
  flake,
  inputs,
  ...
}: {
  imports = [
    flake.homeModules.common
    flake.homeModules.class-laptop
    inputs.agenix.homeManagerModules.default
  ];
}
