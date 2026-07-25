_: {
  flake.modules.homeManager.nix_index = {
    inputs,
    pkgs,
    ...
  }: {
    imports = [inputs.nix-index-database.homeModules.nix-index];
    home.packages = [pkgs.comma];
  };
}
