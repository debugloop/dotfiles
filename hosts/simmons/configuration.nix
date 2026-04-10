{flake, ...}: {
  imports = [
    ./hardware-configuration.nix
    flake.nixosModules.common
    flake.nixosModules.class-laptop
  ];

  backup.enable = true;
  system.stateVersion = "22.11";

  codingVmsExternalInterface = "wlp2s0";

  codingVms = [
    {
      name = "codingvm";
      workspace = "/home/danieln/microvm/coding";
    }
  ];

  programs = {
    gamemode.enable = true;
    steam.enable = true;
  };
  # environment.systemPackages = with pkgs; [
  #   factorio
  # ];
}
