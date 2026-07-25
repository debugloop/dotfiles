_: {
  flake.modules.nixos.profile_development = {
    config,
    inputs,
    ...
  }: {
    imports = with inputs.self.modules.nixos; [
      ai
      devtools
      go
      kubernetes
    ];

    home-manager.users.${config.mainUser}.imports = [inputs.self.modules.homeManager.profile_development];
  };

  flake.modules.homeManager.profile_development = {inputs, ...}: {
    imports = with inputs.self.modules.homeManager; [
      ai
      devtools
      extras
      git_tools
      go
      kubernetes
      language_tooling
      nix_index
    ];
  };
}
