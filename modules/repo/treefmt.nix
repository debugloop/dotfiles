{inputs, ...}: {
  flake-file.inputs = {
    treefmt-nix.url = "github:numtide/treefmt-nix";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
  };

  imports = [inputs.treefmt-nix.flakeModule inputs.git-hooks-nix.flakeModule];

  perSystem = {
    config,
    lib,
    ...
  }: {
    apps.fmt = {
      type = "app";
      program = lib.getExe config.formatter;
      meta.description = "Format the repository";
    };

    treefmt = {
      projectRootFile = "flake.nix";
      programs = {
        alejandra.enable = true;
        mdformat = {
          enable = true;
          plugins = ps: [ps.mdformat-frontmatter];
          settings.number = true;
        };
        deadnix.enable = true;
        statix.enable = true;
        stylua.enable = true;
      };
    };
    pre-commit.settings.hooks.treefmt.enable = true;
  };
}
