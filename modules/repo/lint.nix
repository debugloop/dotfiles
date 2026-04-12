{inputs, ...}: {
  imports = [inputs.git-hooks-nix.flakeModule];

  perSystem = _: {
    pre-commit.settings.hooks = {
      deadnix.enable = true;
      statix.enable = true;
    };
  };
}
