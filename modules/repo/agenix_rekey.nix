{inputs, ...}: {
  imports = [inputs.agenix-rekey.flakeModule];

  perSystem = {config, ...}: {
    agenix-rekey = {
      homeConfigurations = {};
      collectHomeManagerConfigurations = false;
    };

    packages.agenix = config.agenix-rekey.package;
  };
}
