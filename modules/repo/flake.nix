{inputs, ...}: {
  imports = [inputs.flake-parts.flakeModules.modules];

  flake.checks.x86_64-linux = {
    roshar = inputs.self.nixosConfigurations.roshar.config.system.build.toplevel;
    simmons = inputs.self.nixosConfigurations.simmons.config.system.build.toplevel;
  };
}
