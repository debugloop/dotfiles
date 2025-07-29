{flake, ...}: {
  imports = [
    ./hardware-configuration.nix
    flake.nixosModules.common
    flake.nixosModules.class-laptop
    flake.nixosModules.has-backup
  ];

  programs = {
    gamemode.enable = true;
    steam.enable = true;
  };
  # environment.systemPackages = with pkgs; [
  #   factorio
  # ];
}
