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
        common_base
        common_claude
        common_cloud
        common_colors
        common_development
        common_extra
        common_fish
        common_git
        common_helix
        common_network
        common_nix
        common_nvim
        common_session
        common_ssh
        common_starship
      ])
      ++ [inputs.agenix.homeManagerModules.default];
  };
}
