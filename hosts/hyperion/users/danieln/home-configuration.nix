{
  flake,
  inputs,
  ...
}: {
  imports = [
    flake.homeModules.common
    flake.homeModules.class-server
    inputs.agenix.homeManagerModules.default
  ];
}
