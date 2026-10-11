{inputs, ...}: {
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.flake-file.flakeModules.default
    inputs.flake-file.flakeModules.auto-follow
  ];

  systems = ["x86_64-linux"];

  flake-file = {
    description = "debugloop/dotfiles";
    formatter = pkgs: pkgs.alejandra;
    outputs = ''
      inputs:
        inputs.flake-parts.lib.mkFlake { inherit inputs; } {
          imports = import ./lib/import-tree.nix ./modules;
        }
    '';
    inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      flake-parts = {
        url = "github:hercules-ci/flake-parts";
        inputs.nixpkgs-lib.follows = "nixpkgs";
      };
      flake-file.url = "github:denful/flake-file";
    };
  };

  flake.checks.x86_64-linux = {
    delos = inputs.self.nixosConfigurations.delos.config.system.build.toplevel;
    roshar = inputs.self.nixosConfigurations.roshar.config.system.build.toplevel;
    simmons = inputs.self.nixosConfigurations.simmons.config.system.build.toplevel;
    home_generic_linux = inputs.self.homeConfigurations.danieln.activationPackage;
  };
}
