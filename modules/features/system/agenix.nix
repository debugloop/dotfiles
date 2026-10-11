_: {
  flake-file.inputs.agenix.url = "github:ryantm/agenix";

  flake.modules.nixos.agenix = {inputs, ...}: {
    imports = [inputs.agenix.nixosModules.default];
  };

  flake.modules.homeManager.agenix = {
    config,
    inputs,
    ...
  }: {
    imports = [inputs.agenix.homeManagerModules.default];

    age.identityPaths = ["${config.home.homeDirectory}/.ssh/agenix"];
  };
}
