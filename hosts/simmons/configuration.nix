{flake, ...}: {
  imports = [
    ./hardware-configuration.nix
    flake.nixosModules.common
    flake.nixosModules.class-laptop
  ];

  backup.enable = true;
  system.stateVersion = "22.11";

  programs = {
    gamemode.enable = true;
    steam.enable = true;
  };
  # environment.systemPackages = with pkgs; [
  #   factorio
  # ];
}
