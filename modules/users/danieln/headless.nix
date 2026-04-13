_: {
  flake.modules.homeManager.danieln_headless = {inputs, ...}: {
    home = {
      username = "danieln";
      homeDirectory = "/home/danieln";
    };

    imports =
      (with inputs.self.modules.homeManager; [
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
