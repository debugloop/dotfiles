{inputs, ...}: {
  flake-file.inputs.agenix-rekey = {
    url = "github:oddlama/agenix-rekey";
    inputs = {
      flake-compat.follows = "git-hooks-nix/flake-compat";
      pre-commit-hooks.follows = "git-hooks-nix";
    };
  };

  imports = [inputs.agenix-rekey.flakeModule];

  perSystem = {config, ...}: {
    agenix-rekey = {
      homeConfigurations = {};
      collectHomeManagerConfigurations = false;
    };

    packages.agenix = config.agenix-rekey.package;
  };
}
