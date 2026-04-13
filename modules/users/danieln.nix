_: {
  flake.homeModules.danieln = {
    top,
    inputs,
    ...
  }: {
    home = {
      username = "danieln";
      homeDirectory = "/home/danieln";
    };

    imports =
      (with top.homeModules; [
        base
        claude
        cloud
        colors
        development
        extra
        fish
        git
        helix
        network
        nix
        nvim
        session
        ssh
        starship
      ])
      ++ [inputs.agenix.homeManagerModules.default];
  };
}
