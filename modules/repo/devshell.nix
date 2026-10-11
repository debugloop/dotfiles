_: {
  perSystem = {
    pkgs,
    config,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      shellHook = config.pre-commit.installationScript;
      inputsFrom = [config.pre-commit.devShell];
      packages = [
        config.agenix-rekey.package
        pkgs.age-plugin-fido2-hmac
      ];
    };
  };
}
