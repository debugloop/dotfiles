{inputs, ...}: {
  imports = [inputs.git-hooks-nix.flakeModule];

  perSystem = {
    config,
    lib,
    pkgs,
    ...
  }: let
    followCommand = "flake-edit --no-lock --non-interactive --no-cache --config flake-edit.toml follow";
    fmtInputs = pkgs.writeShellApplication {
      name = "fmt-inputs";
      runtimeInputs = [pkgs.flake-edit pkgs.git pkgs.nix];
      text = ''
        cd "$(git rev-parse --show-toplevel)"
        nix flake lock
        ${followCommand}
        nix flake lock --offline
      '';
    };
  in {
    apps.fmt-inputs = {
      type = "app";
      program = lib.getExe fmtInputs;
      meta.description = "Set input follows and reconcile the lock file";
    };

    pre-commit.settings.hooks.fmt-inputs = {
      enable = true;
      name = "Set input follows";
      package = fmtInputs;
      entry = lib.getExe fmtInputs;
      files = "^(flake\\.(nix|lock)|flake-edit\\.toml)$";
      pass_filenames = false;
      require_serial = true;
      before = ["treefmt"];
    };

    checks = {
      flake-follows =
        pkgs.runCommand "check-flake-follows" {
          nativeBuildInputs = [pkgs.flake-edit pkgs.diffutils];
        } ''
          cp ${inputs.self}/flake.nix ${inputs.self}/flake.lock ${inputs.self}/flake-edit.toml .
          chmod u+w flake.nix
          ${followCommand}
          if ! diff -u ${inputs.self}/flake.nix flake.nix; then
            echo 'Input follows are stale. Run: nix run .#fmt-inputs' >&2
            exit 1
          fi
          touch "$out"
        '';

      # Check follows separately because the maintenance hook needs Nix store access.
      pre-commit = lib.mkForce (config.pre-commit.settings.run.overrideAttrs (old: {
        SKIP = lib.concatStringsSep "," (lib.optional (old ? SKIP) old.SKIP ++ ["fmt-inputs"]);
      }));
    };
  };
}
