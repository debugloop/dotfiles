{
  inputs,
  self,
  ...
}: {
  # First installation from the dotfiles checkout on a non-NixOS host:
  #   nix run .#home
  flake.apps.x86_64-linux.home = {
    type = "app";
    meta.description = "Activate danieln's generic Linux Home Manager configuration";
    program = "${self.homeConfigurations.danieln.activationPackage}/activate";
  };

  flake.homeConfigurations.danieln = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
    extraSpecialArgs = {
      inherit inputs;
      mainUser = "danieln";
    };
    modules = [
      self.modules.homeManager.profile_user_base
      self.modules.homeManager.profile_development
      ({config, ...}: {
        dotfiles.root = "${config.home.homeDirectory}/.config/dotfiles";
        home.stateVersion = "22.11";
        targets.genericLinux.enable = true;
      })
    ];
  };
}
