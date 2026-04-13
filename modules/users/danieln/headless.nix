_: {
  flake.homeModules.danieln_headless = {
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
        ai
        base
        claude
        colors
        development
        extra
        fish
        git
        helix
        network
        nix
        nvim
        online
        session
        ssh
        starship
      ])
      ++ [inputs.agenix.homeManagerModules.default];
  };
}
