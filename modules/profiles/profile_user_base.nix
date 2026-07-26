_: {
  flake.modules.homeManager.profile_user_base = {
    inputs,
    mainUser,
    ...
  }: {
    home = {
      username = mainUser;
      homeDirectory = "/home/${mainUser}";
    };

    imports = with inputs.self.modules.homeManager; [
      dotfiles
      agenix
      colors
      coretools
      fish
      git
      network
      nix
      nvim
      session
      ssh
      starship
    ];
  };
}
