{flake, ...}: {
  imports = [
    ./hardware-configuration.nix
    flake.nixosModules.common
    flake.nixosModules.class-laptop
    flake.nixosModules.has-backup
  ];

  system.stateVersion = "22.11";

  programs = {
    gamemode.enable = true;
    steam.enable = true;
  };
  # environment.systemPackages = with pkgs; [
  #   factorio
  # ];
}
