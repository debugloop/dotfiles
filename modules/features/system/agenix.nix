_: {
  flake.modules.nixos.agenix = {inputs, ...}: {
    imports = [inputs.agenix.nixosModules.default];

    age.secrets.password.file = inputs.self + "/secrets/password.age";
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
