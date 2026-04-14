{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule inputs.git-hooks-nix.flakeModule];

  perSystem = _: {
    treefmt = {
      projectRootFile = "flake.nix";
      programs = {
        alejandra.enable = true;
        mdformat.enable = true;
        deadnix.enable = true;
        statix.enable = true;
        stylua.enable = true;
      };
    };
    pre-commit.settings.hooks.treefmt.enable = true;
  };
}
