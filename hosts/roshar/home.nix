{top, inputs, ...}: {
  home = {
    username = "danieln";
    homeDirectory = "/home/danieln";
    stateVersion = "22.11";
  };

  imports = with top.modules.home; [
    common_base
    common_network
    common_session
    common_ssh
    common_claude
    common_cloud
    common_colors
    common_development
    common_extra
    common_fish
    common_git
    common_helix
    common_nix
    common_nvim
    common_starship
    server_base
  ] ++ [inputs.agenix.homeManagerModules.default];
}
