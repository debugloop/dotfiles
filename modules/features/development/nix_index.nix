_: {
  flake-file.inputs.nix-index-database.url = "github:Mic92/nix-index-database";

  flake.modules.homeManager.nix_index = {
    inputs,
    pkgs,
    ...
  }: {
    imports = [inputs.nix-index-database.homeModules.nix-index];
    home.packages = [pkgs.comma];
  };
}
