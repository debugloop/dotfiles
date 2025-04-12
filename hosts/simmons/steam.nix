{
  pkgs,
  lib,
  ...
}: {
  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
  };

  # environment.systemPackages = with pkgs; [
  #   factorio
  # ];
}
