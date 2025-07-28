{flake, ...}: {
  imports = [
    flake.nixosModules.common
    flake.nixosModules.laptops
    ./backup.nix
    ./boot.nix
    ./steam.nix
  ];

  programs = {
    gamemode.enable = true;
    steam.enable = true;
  };
  # environment.systemPackages = with pkgs; [
  #   factorio
  # ];
}
